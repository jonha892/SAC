FROM python:3.7.4-alpine3.10

COPY ./requirements.txt ./
COPY ./SAC.py ./

RUN pip install -r ./requirements.txt

ENTRYPOINT ["python3", "./SAC.py"]