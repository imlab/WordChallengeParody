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
from django.http import HttpResponseRedirect, HttpResponse, HttpResponseNotFound, HttpResponseForbidden
from django.views.decorators.csrf import csrf_exempt 
from gamecenter.models import *
from gamecenter import gamecenter_pb2


@csrf_exempt
def gamecenter(request):
  # clear user's seat reservation
  userId = request.session.get('userId')
  if userId:
    sessionUser = User.objects.get(id=userId)
    sessionUser.clearRoomSeat()

  rooms = Room.objects.all()
  
  result = gamecenter_pb2.GameCenterResponse()
  for r in rooms:
    resultRoom = result.rooms.add()
    resultRoom.roomId = r.id
    resultRoom.roomName = r.roomName
    resultRoom.numberOfUsers = r.getNumberOfUsers()
    resultRoom.totalSeats = r.totalSeats
    
  print 'response: ', repr(result.SerializeToString())
  return HttpResponse(result.SerializeToString(), content_type="application/x-protobuf")

@csrf_exempt
def join_room(request, roomId):
  userId = request.session.get('userId')
  print "room id: %d userId:" % int(roomId), userId
  
  response = gamecenter_pb2.RoomStatusResponse()
  if not userId:
    response.roomStatus = gamecenter_pb2.RoomStatusResponse.USER_INVALID
  elif not roomId or not Room.objects.get(id=int(roomId)): 
    response.roomStatus = gamecenter_pb2.RoomStatusResponse.ROOM_UNAVAILABLE
  else:
    room = Room.objects.get(id=int(roomId))
    if not room.isSeatAvailable():
      response.roomStatus = gamecenter_pb2.RoomStatusResponse.SEAT_UNAVAILABLE
    else:
      if not room.isUserInRoom(userId):
        room.addUser(userId)
      response.roomStatus = gamecenter_pb2.RoomStatusResponse.JOIN_SUCCESS
      gameUsers = room.getGameUsers()
      for gu in gameUsers:
        user = response.users.add()
        user.userId = gu.user.id
        user.userName = gu.user.userName
        user.userStatus = gu.status

  print "response: ", repr(response.SerializeToString())
  return HttpResponse(response.SerializeToString(), content_type="application/x-protobuf")


@csrf_exempt
def start_game(request, roomId):
  userId = request.session.get('userId')
  print "room id: %d userId:" % int(roomId), userId
 
  response = gamecenter_pb2.GameStatusResponse()
  if not userId or not Game.objects.filter(room__id__exact=int(roomId), user__id__exact=userId):
    return HttpResponseForbidden('')
  else:
    # change user status to start game
    currentUser = Game.objects.get(room__id__exact=int(roomId), user__id__exact=userId);
    currentUser.status = gamecenter_pb2.User.CONFIRMED
    currentUser.save()

    # compose the user status list to response
    gameUsers = Room.objects.get(id=int(roomId)).getGameUsers()
    for gu in gameUsers:
      user = response.statusList.add()
      user.userId = gu.user.id
      user.userName = gu.user.userName
      user.userStatus = gu.status
      user.points = gu.points
      user.time = gu.time
    
  print "response: ", repr(response.SerializeToString())
  return HttpResponse(response.SerializeToString(), content_type="application/x-protobuf")


@csrf_exempt
def update_game(request, roomId):
  userId = request.session.get('userId')
  print "room id: %d userId:" % int(roomId), userId

  # get user status from request
  newStatus = gamecenter_pb2.GameStatusRequest()
  newStatus.ParseFromString(request.raw_post_data)
  print "raw: ", repr(request.raw_post_data), " new status:", newStatus

  response = gamecenter_pb2.GameStatusResponse()
  if not userId or not Game.objects.filter(room__id__exact=int(roomId), user__id__exact=userId):
    return HttpResponseForbidden('')
  else:
    if newStatus:
      print "user time: %d points: %d" % (newStatus.time, newStatus.points)
      # update user status
      currentUser = Game.objects.get(room__id__exact=int(roomId), user__id__exact=userId);
      # play/end game status transition
      if newStatus.time == 0:
        currentUser.status = gamecenter_pb2.User.END
      elif newStatus.time > 0 and currentUser.status == gamecenter_pb2.User.CONFIRMED:
        currentUser.status = gamecenter_pb2.User.PLAY
      currentUser.points = newStatus.points
      currentUser.time = newStatus.time  
      currentUser.save()

    # compose the user status list to response
    gameUsers = Room.objects.get(id=int(roomId)).getGameUsers()
    for gu in gameUsers:
      user = response.statusList.add()
      user.userId = gu.user.id
      user.userStatus = gu.status
      user.points = gu.points
      user.time = gu.time

  print "response: ", repr(response.SerializeToString())
  return HttpResponse(response.SerializeToString(), content_type="application/x-protobuf")


