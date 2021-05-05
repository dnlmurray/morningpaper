import datetime

from sqlalchemy import Column, Integer, BigInteger, Time, ForeignKey, String, Float, Table, MetaData
from sqlalchemy.orm import registry, relationship, declarative_base

mapper_registry = registry()

Base = declarative_base()


class Location(Base):
    __tablename__ = 'locations'

    id = Column(Integer, primary_key=True)
    location = Column(String(30))
    lat = Column(Float)
    lon = Column(Float)


class Topic(Base):
    __tablename__ = 'topics'

    id = Column(Integer, primary_key=True)
    name = Column(String(30))

    users = relationship('User', secondary='users_topics')


class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    user_id = Column(BigInteger)
    preferred_time = Column(Time)
    locations_id = Column(Integer, ForeignKey('locations.id'))

    topics = relationship('Topic', secondary='users_topics')


class UsersLocations(Base):
    __tablename__ = 'users_topics'

    users_id = Column(Integer, ForeignKey('users.id'), primary_key=True)
    topics_id = Column(Integer, ForeignKey('topics.id'), primary_key=True)

    user = relationship(User, backref='users_topics')
    topic = relationship(Topic, backref='users_topics')

