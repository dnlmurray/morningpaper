import os
import sys
from time import strptime as parse_time
from time import strftime as print_time

from aiogram import Bot, Dispatcher, types
from aiogram.contrib.fsm_storage.memory import MemoryStorage
from aiogram.dispatcher import FSMContext
from aiogram.dispatcher.filters import Text
from aiogram.dispatcher.filters.state import StatesGroup, State
from aiogram.types import ReplyKeyboardMarkup, KeyboardButton, ReplyKeyboardRemove
from aiogram.utils import executor
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

import database
import orm

BOT_TOKEN = os.getenv('BOT_TOKEN')
if not BOT_TOKEN:
    sys.exit("No bot token was found in ENV. Set 'BOT_TOKEN' variable to your token from @BotFather")
bot = Bot(BOT_TOKEN)
dispatcher = Dispatcher(bot, storage=MemoryStorage())  # TODO: Consider using more advanced storage


class TopicSetter(StatesGroup):
    process_topics = State()


class LocationSetter(StatesGroup):
    process_location = State()


class TimeSetter(StatesGroup):
    set_time = State()


class CurrencySetter(StatesGroup):
    set_base = State()
    set_target_one = State()
    set_target_two = State()
    review = State()


def init():
    executor.start_polling(dispatcher, skip_updates=True)


@dispatcher.message_handler(commands='start')
async def send_hello(message: types.message):
    with Session(database.engine) as session:
        try:
            session.add(orm.User(user_id=message.from_user.id))
            session.commit()
        except IntegrityError:
            await message.answer("Hey! I already know you. Use /help command to get more information")
            return
        await message.answer("Hello! I am Morning Paper Bot. Currently under development.\n"
                             "Type /help to get more information")


@dispatcher.message_handler(commands='help')
async def send_help(message: types.message):
    await message.answer("I can send you fresh news everyday.\n"
                         "My commands are: /topics, /currency, /city, /time, /review, /cancel /help")


@dispatcher.message_handler(commands='cancel', state='*')
@dispatcher.message_handler(Text(equals='cancel', ignore_case=True), state='*')
async def cancel_handler(message: types.Message, state: FSMContext):
    current_state = await state.get_state()
    if current_state is None:
        await message.answer('There is nothing to cancel')
        return
    await state.finish()
    await message.answer('Action cancelled', reply_markup=ReplyKeyboardRemove())


topics_keyboard = ReplyKeyboardMarkup(resize_keyboard=True)
topics_keyboard.row(
    KeyboardButton('Business'),
    KeyboardButton('Entertainment'),
    KeyboardButton('Technology')
)
topics_keyboard.row(
    KeyboardButton('Health'),
    KeyboardButton('Science'),
    KeyboardButton('Sports'),
    KeyboardButton('General')
)
topics_keyboard.row(
    KeyboardButton('Cancel'),
    KeyboardButton('Apply')
)


@dispatcher.message_handler(commands='topics')
async def set_topics(message: types.message, state: FSMContext):
    with Session(database.engine) as session:
        user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
        user = session.execute(user_select).scalar()
        users_topics = set(topic.name for topic in user.topics)
        await state.update_data(topics=users_topics)
    await TopicSetter.process_topics.set()
    await message.answer('Now you can edit news topics.')
    if not users_topics:
        await message.answer('You don\'t have any topics selected', reply_markup=topics_keyboard)
    else:
        await message.answer('Your current topics are: ' + ', '.join(users_topics), reply_markup=topics_keyboard)


@dispatcher.message_handler(state=TopicSetter.process_topics)
async def process_topics(message: types.Message, state: FSMContext):
    data = await state.get_data()
    topics = data.get('topics')
    user_reply = message.text.lower()
    if user_reply == 'apply':
        await apply_topics(message, state)
        return
    elif user_reply in topics:
        topics.remove(user_reply)
    else:
        topics.add(user_reply)
    await state.update_data(topics=topics)
    if not topics:
        await message.answer('You don\'t have any topics selected', reply_markup=topics_keyboard)
    else:
        await message.answer('Your current topics are: ' + ', '.join(topics), reply_markup=topics_keyboard)


async def apply_topics(message: types.message, state: FSMContext):
    data = await state.get_data()
    topics = data.get('topics')
    with Session(database.engine) as session:
        user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
        user = session.execute(user_select).scalar()
        topics_select = select(orm.Topic).filter(orm.Topic.name.in_(topics))
        users_topics = session.execute(topics_select).scalars()
        user.topics = []
        for topic in users_topics:
            user.topics.append(topic)
        session.commit()
    await state.finish()
    if not topics:
        await message.answer('You didn\'t chose any topics', reply_markup=ReplyKeyboardRemove())
    else:
        await message.answer('You have chosen the following topics: ' + ', '.join(topics),
                             reply_markup=ReplyKeyboardRemove())


currency_keyboard = ReplyKeyboardMarkup(resize_keyboard=True)
for currency in Session(database.engine).execute(select(orm.Currency)).scalars():
    currency_keyboard.insert(KeyboardButton(f'{currency.name} ({currency.abbreviation})'))
currency_keyboard.row(
    KeyboardButton('Cancel')
)

finish_keyboard = ReplyKeyboardMarkup(resize_keyboard=True).add('Finish')


@dispatcher.message_handler(commands='currency')
async def set_currency(message: types.message):
    await message.answer("Now you can set your base currency and two target currencies")
    await message.answer("Set your base currency", reply_markup=currency_keyboard)
    await CurrencySetter.set_base.set()


def process_currency(message: types.message):
    for currency in Session(database.engine).execute(select(orm.Currency)).scalars():
        if message.text.lower() == currency.name.lower() or \
                message.text.lower() == currency.abbreviation.lower() or \
                message.text == currency.name + f' ({currency.abbreviation})':
            return currency
    return None


@dispatcher.message_handler(state=CurrencySetter.set_base)
async def set_base_currency(message: types.message, state: FSMContext):
    currency = process_currency(message)
    if currency:
        await message.answer(f'Your base currency is {currency.name}')
        await message.answer('Set your first target currency')
        await state.update_data(base_currency=currency)
        await CurrencySetter.next()
    else:
        await message.answer("Please choose one of the available options")


@dispatcher.message_handler(state=CurrencySetter.set_target_one)
async def set_base_currency(message: types.message, state: FSMContext):
    currency = process_currency(message)
    if currency:
        await message.answer(f'Your first target currency is {currency.name}')
        await message.answer('Set your second target currency')
        await state.update_data(target_one_currency=currency)
        await CurrencySetter.next()
    else:
        await message.answer("Please choose one of the available options")


@dispatcher.message_handler(state=CurrencySetter.set_target_two)
async def set_base_currency(message: types.message, state: FSMContext):
    currency = process_currency(message)
    if currency:
        await message.answer(f'Your second target currency is {currency.name}', reply_markup=finish_keyboard)
        await state.update_data(target_two_currency=currency)
        await CurrencySetter.next()
    else:
        await message.answer("Please choose one of the available options")


@dispatcher.message_handler(state=CurrencySetter.review)
async def apply_currencies(message: types.message, state: FSMContext):
    data = await state.get_data()
    base = data.get('base_currency')
    target_one = data.get('target_one_currency')
    target_two = data.get('target_two_currency')
    await message.answer(f'You will get information about price of {target_one.name} and {target_two.name} '
                         f'in {base.name}', reply_markup=ReplyKeyboardRemove())
    with Session(database.engine) as session:
        users_currencies_select = select(orm.UsersCurrencies).join(orm.User).where(
            orm.User.user_id == message.from_user.id)
        users_currencies = session.execute(users_currencies_select).scalar()
        if users_currencies is None:
            user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
            user = session.execute(user_select).scalar()
            users_currencies = orm.UsersCurrencies(users_id=user.id)
        users_currencies.base = base.id
        users_currencies.target_one = target_one.id
        users_currencies.target_two = target_two.id
        session.add(users_currencies)
        session.commit()
    await state.finish()


@dispatcher.message_handler(commands='city')
async def set_city(message: types.message):
    await message.answer("What is your city?")
    await LocationSetter.process_location.set()


@dispatcher.message_handler(state=LocationSetter.process_location)
async def process_location(message: types.message, state: FSMContext):
    with Session(database.engine) as session:
        check_location(message.text)
        location_select = select(orm.Location).where(orm.Location.location == message.text)
        location = session.execute(location_select).scalar()
        user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
        user = session.execute(user_select).scalar()
        user.location = location
        session.add(user)
        session.commit()
        await state.finish()
        await message.answer(f'Your location is {location.location}')


def check_location(name: str):
    with Session(database.engine) as session:
        location = orm.Location(location=name, lat=0.0, lon=0.0)
        session.add(location)
        session.commit()


@dispatcher.message_handler(commands='time')
async def set_time(message: types.message):
    await message.answer("Please type time in 24h format (like `15:30`)", parse_mode='markdown')
    await TimeSetter.set_time.set()


@dispatcher.message_handler(state=TimeSetter.set_time)
async def process_time(message: types.message, state: FSMContext):
    try:
        time = parse_time(message.text, '%H:%M')  # Using time module to avoid dealing with regexes
        with Session(database.engine) as session:
            user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
            user = session.execute(user_select).scalar()
            user.preferred_time = print_time('%H:%M', time)
            session.commit()
        await message.answer(f'You will get your news at {print_time("%H:%M", time)}')
        await state.finish()
    except ValueError:
        await message.answer('Please follow format: 24h format, delimiter is colon. Don\'t use spaces!\n'
                             'You can use /cancel command to exit time settings')


@dispatcher.message_handler(commands='review')
async def review(message: types.message):
    with Session(database.engine) as session:
        user_select = select(orm.User).where(orm.User.user_id == message.from_user.id)
        user = session.execute(user_select).scalar()
        currency_select = select(orm.UsersCurrencies).where(orm.UsersCurrencies.users_id == user.id)
        currencies = session.execute(currency_select).scalar()
        if currencies is None:
            # if user have not set their currencies, use dummy object for easier code
            currencies = orm.UsersCurrencies()
        currency_names = [session.execute(select(orm.Currency).where(orm.Currency.id == currency)).scalar().name
                          for currency in (currencies.base, currencies.target_one, currencies.target_two)]
        settings = f"This are your current settings:\n" \
                   f"Topics: {(', '.join(topic.name for topic in user.topics) if user.topics else 'None')}\n" \
                   f"Time: {str(user.preferred_time)}\n" \
                   f"City: {str(user.location.location)}\n" \
                   f"Currencies: from {str(currency_names[0])} to " \
                   f"{str(currency_names[1])} and {str(currency_names[2])}"
        await message.answer(settings)
