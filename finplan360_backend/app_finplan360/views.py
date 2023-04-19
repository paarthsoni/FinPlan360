import json
from django.http import JsonResponse
from django.shortcuts import render, HttpResponse
from app_finplan360 import urls
from django.views.decorators.csrf import csrf_exempt
from .models import useraccount
import requests
from datetime import datetime
import bcrypt
from django.contrib.auth.hashers import make_password, check_password


@csrf_exempt
def useraccountdetails(request):
    firstname = request.POST.get("firstname")
    lastname = request.POST.get("lastname")
    dob = request.POST.get("dob")
    username = request.POST.get("username")
    password = request.POST.get("password")
    hashed_pwd = make_password(password)
    aadharorpan = request.POST.get("aadharorpan")

    print(firstname, lastname, dob, username, password, aadharorpan)
    flag = 0
    if (useraccount.objects.filter(username=username).exists()):
        flag = 1

    if flag != 1:
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

            response = requests.request(
                "POST", url, json=payload, headers=headers)

            # print(response.text)
            response = response.json()

            if 'result' in response:
                fname = response['result']['source_output']['first_name']
                lname = response['result']['source_output']['last_name']
                if firstname == fname and lastname == lname:
                    bytepan = aadharorpan.encode('utf-8')
                    mySalt = bcrypt.gensalt()
                    hashedpan = bcrypt.hashpw(bytepan, mySalt)
                    userdata = useraccount(firstname=firstname, lastname=lastname, dob=dob, username=username,
                                           password=hashed_pwd, panoraadhar=hashedpan, acc_creation_date=datetime.now())
                    userdata.save()
                    # print("matched")
                    return JsonResponse({'response': 'Account Created Sucessfully'})

            elif 'result' not in response:
                return JsonResponse({'response': 'Invalid Pan number'})
        # elif len(aadharorpan) == 12:
        #     d

        else:
            return JsonResponse({'response': 'Invalid Pan number'})
    elif flag == 1:
        return JsonResponse({'response': 'Username already exists'})


@csrf_exempt
def userlogin(request):
    username = request.POST.get("username")
    password = request.POST.get("password")
    print(username, password)

    if useraccount.objects.filter(username=username).exists():

        user = useraccount.objects.get(username=username)
        userpassword = user.password
        result = check_password(password, userpassword)

        if result == True:
            print("user logged in")
            useraccount.objects.filter(
                username=username).update(is_authenticated='yes')

            return JsonResponse({'response': 'logged in'})

        else:
            print("invalid username or password")
            return JsonResponse({'response': 'invalid username or password'})
    else:
        print("invalid username or password")
        return JsonResponse({'response': 'invalid username or password'})


@csrf_exempt
def userlogout(request):
    username = request.POST.get('username')
    useraccount.objects.filter(
        username=username).update(is_authenticated='no')
    print(username)
    return JsonResponse({'response': 'logged out'})
