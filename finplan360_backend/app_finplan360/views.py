import http.client
import json
from django.shortcuts import render, HttpResponse
from app_finplan360 import urls
from django.views.decorators.csrf import csrf_exempt
from .models import useraccount
import requests


@csrf_exempt
def useraccount(request):
    fullname = request.POST.get("fullname")
    dob = request.POST.get("dob")
    username = request.POST.get("username")
    password = request.POST.get("password")
    aadharorpan = request.POST.get("aadharorpan")
    print(fullname, dob, username, password, aadharorpan)

    if len(aadharorpan) == 10:

        url = "https://pan-card-verification1.p.rapidapi.com/v3/tasks/sync/verify_with_source/ind_pan"

        payload = {
            "task_id": "74f4c926-250c-43ca-9c53-453e87ceacd1",
            "group_id": "8e16424a-58fc-4ba4-ab20-5bc8e7c3c41e",
            "data": {"id_number": aadharorpan}
        }
        headers = {
            "content-type": "application/json",
            "X-RapidAPI-Key": "30958d0e79mshbf7479782f1df77p141c9ajsnc300431445bf",
            "X-RapidAPI-Host": "pan-card-verification1.p.rapidapi.com"
        }

        response = requests.request("POST", url, json=payload, headers=headers)

        print(response.text)
        response = response.json()
        fname = response['result']['source_output']['first_name']
        print(response['result']['source_output']['first_name'])

        if (fullname == fname):
            print("matched")

    elif len(aadharorpan) == 12:
        d
    return HttpResponse("hello")
