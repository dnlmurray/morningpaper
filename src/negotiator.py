import os
import sys

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
        await message.answer('You have chosen the following topics: ' + ', '.join(topics),
                             reply_markup=ReplyKeyboardRemove())


@dispatcher.message_handler(commands='currency')
async def set_currency(message: types.message):
    await message.answer("This command will allow you to set currencies you want to get.\n"
                         "Currently does nothing")


@dispatcher.message_handler(commands='city')
async def set_city(message: types.message):
    await message.answer("This command will allow you to set city in which you'll get weather forecast.\n"
                         "Currently does nothing")


@dispatcher.message_handler(commands='time')
async def set_time(message: types.message):
    await message.answer("This command will allow you to set time when you want to read news.\n"
                         "Currently does nothing")


@dispatcher.message_handler(commands='review')
async def review(message: types.message):
    await message.answer("This command will allow you to view your current settings.\n"
                         "Currently does nothing")
