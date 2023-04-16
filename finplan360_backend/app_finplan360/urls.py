from django.contrib import admin
from django.urls import path, include

from app_finplan360 import views

urlpatterns = [

    path('register', views.useraccountdetails, name="userdetails"),
    path('login', views.userlogin, name="userlogin"),
    path('logout', views.userlogout, name="userlogout"),
]
