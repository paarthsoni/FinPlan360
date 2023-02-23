from django.shortcuts import render, HttpResponse
from app_finplan360 import urls
# Create your views here.


def hello(request):
    return HttpResponse("hello")
