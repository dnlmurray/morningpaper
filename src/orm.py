import datetime

from sqlalchemy import Column, Integer, BigInteger, Time, ForeignKey, String, Float, Table, MetaData, TIMESTAMP
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

    news = relationship('News')


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


class Source(Base):
    __tablename__ = 'sources'

    id = Column(Integer, primary_key=True)
    name = Column(String(30))
    link = Column(String(80))

    news = relationship('News')


class News(Base):
    __tablename__ = 'news'

    id = Column(Integer, primary_key=True)
    heading = Column(String(280))
    summary = Column(String(1000))
    author = Column(String(30))
    link = Column(String(100))
    timestamp = Column(TIMESTAMP)

    sources_id = Column(Integer, ForeignKey('sources.id'))
    topics_id = Column(Integer, ForeignKey('topics.id'))
