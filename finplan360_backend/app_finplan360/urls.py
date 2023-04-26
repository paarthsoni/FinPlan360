from django.contrib import admin
from django.urls import path, include

from app_finplan360 import views

urlpatterns = [

    path('register', views.useraccountdetails, name="userdetails"),
    path('login', views.userlogin, name="userlogin"),
    path('logout', views.userlogout, name="userlogout"),
    path('is_authenticated', views.isauthenticated, name="isauthenticated"),
    path('salary', views.add_salary, name="salary"),
    path('messages', views.debit_messages, name="debit_messages"),
    path('getmessages', views.getuncategorizedmessages,
         name="getuncategorizedmessages"),
]
