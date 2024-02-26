FROM python
WORKDIR /code
COPY . .
ENV PYTHONUNBUFFERED=1
EXPOSE 5000
RUN pip install -r requirements.txt
CMD ["python3","app.py"]