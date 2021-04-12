FROM python:3

WORKDIR /usr/morningpaper/

RUN pip install pipenv
COPY src/ Pipfile Pipfile.lock ./
RUN pipenv install --system --deploy --ignore-pipfile

CMD python main.py