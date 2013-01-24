#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#
#  Created on 12-12-12.
#  Copyright (c) 2012年 imlab.cc All rights reserved.
#

# Create your views here.
from django.http import HttpResponseRedirect, HttpResponse
from login_pb2 import LoginRequest, LoginResponse
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt 
from gamecenter.models import User

@csrf_exempt
def login(request):
  print 'request: ', repr(request.raw_post_data)
  loginUser = LoginRequest()
  loginUser.ParseFromString(request.raw_post_data)
  print "login user: %s, %s" % (loginUser.username, loginUser.password)

  response = LoginResponse()
  if loginUser.username:
    # save user on server
    user, exitFlag  = User.objects.get_or_create(userName=loginUser.username)
    user.save()
    request.session['userId'] = user.id
    print 'login user id: %d' % user.id
    response.status = LoginResponse.SUCCESS
    response.userId = user.id
  else:
    response.status = LoginResponse.ACCOUNT_INVALID

  # reply login request
  print 'response: ', repr(response.SerializeToString())
  return HttpResponse(response.SerializeToString(), content_type="application/x-protobuf")

@login_required(login_url='/pbauth/signin')
def restricted_app(request):
  return HttpResponse('You\'re now logged in!')

def signin(request):
  return HttpResponse('Send a request to /pbauth/login')
