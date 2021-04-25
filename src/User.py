import datetime
from dataclasses import dataclass, field

from sqlalchemy import Column, Integer, BigInteger, Time, ForeignKey, String, Float
from sqlalchemy.orm import registry, relationship

mapper_registry = registry()


@mapper_registry.mapped
@dataclass
class Location:
    __tablename__ = 'locations'
    __sa_dataclass_metadata_key__ = 'sa'

    id: int = field(init=False, metadata={'sa': Column(Integer, primary_key=True)})
    location: str = field(default=None, metadata={'sa': Column(String(30))})
    lat: float = field(default=None, metadata={'sa': Column(Float)})
    lon: float = field(default=None, metadata={'sa': Column(Float)})


@mapper_registry.mapped
@dataclass
class User:
    __tablename__ = 'users'
    __sa_dataclass_metadata_key__ = 'sa'

    id: int = field(init=False, metadata={'sa': Column(Integer, primary_key=True)})
    uid: int = field(default=None, metadata={'sa': Column(BigInteger)})
    preferred_time: datetime.time = field(default=None, metadata={'sa': Column(Time)})
    locations_id: int = field(default=None, metadata={'sa': Column(Integer, ForeignKey('locations.id'))})
