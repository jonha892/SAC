FROM python:3.7.4-alpine3.10

COPY ./SAC.py ./
COPY ./data/processed.txt ./processed.txt

CMD ["python3", "./SAC.py -s $sender -p $pw -r $recipient -cc $cc -pp ./processed"]