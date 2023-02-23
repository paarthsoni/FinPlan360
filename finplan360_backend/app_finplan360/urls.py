from django.contrib import admin
from django.urls import path, include

from app_finplan360 import views

urlpatterns = [

    path('hello/', views.hello, name="hello"),
]
