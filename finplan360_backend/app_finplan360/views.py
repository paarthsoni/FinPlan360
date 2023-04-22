
from django.http import JsonResponse
from django.shortcuts import render, HttpResponse
from app_finplan360 import urls
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
from .models import useraccount
import requests
from datetime import datetime

from django.contrib.auth.hashers import make_password, check_password
from django.contrib.auth import authenticate, login, logout


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

    resultpan = False
    for e in useraccount.objects.all():
        result = check_password(aadharorpan, e.panoraadhar)
        if result == True:
            resultpan = True
            break

    print(resultpan)
    if flag != 1 and resultpan == False:
        if len(aadharorpan) == 10:

            url = "https://pan-card-verification1.p.rapidapi.com/v3/tasks/sync/verify_with_source/ind_pan"

            payload = {
                "task_id": "74f4c926-250c-43ca-9c53-453e87ceacd1",
                "group_id": "8e16424a-58fc-4ba4-ab20-5bc8e7c3c41e",
                "data": {"id_number": aadharorpan}
            }
            headers = {
                "content-type": "application/json",
                "X-RapidAPI-Key": "1ba039b9dbmsh24028dac9b2690bp191d6ejsnfb265c824e91",
                "X-RapidAPI-Host": "pan-card-verification1.p.rapidapi.com"
            }

            response = requests.request(
                "POST", url, json=payload, headers=headers)

            print(response.text)
            response = response.json()

            if 'result' in response:
                fname = response['result']['source_output']['first_name']
                lname = response['result']['source_output']['last_name']
                if firstname == fname and lastname == lname:

                    user = User.objects.create_user(
                        username=username, password=password)
                    userdata = useraccount(firstname=firstname, lastname=lastname, dob=dob, username=username,
                                           password=hashed_pwd, panoraadhar=make_password(aadharorpan), acc_creation_date=datetime.now())
                    user.save()
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

    elif resultpan == True:
        return JsonResponse({'response': 'Pan exists'})

    # return HttpResponse('v')


@csrf_exempt
def userlogin(request):
    username = request.POST.get("username")
    password = request.POST.get("password")
    print(username, password)

    user = authenticate(username=username, password=password)

    if user is not None:
        print("user logged in")
        useraccount.objects.filter(
            username=username).update(is_authenticated='yes')

        return JsonResponse({'response': 'logged in'})

    else:
        print("invalid username or password")
        return JsonResponse({'response': 'invalid username or password'})


@csrf_exempt
def userlogout(request):
    username = request.POST.get('username')
    logout(request)
    useraccount.objects.filter(
        username=username).update(is_authenticated='no')
    print(username)
    return JsonResponse({'response': 'logged out'})


@csrf_exempt
def isauthenticated(request):
    username=request.POST.get('username')
    print(username)

    return HttpResponse('d')
