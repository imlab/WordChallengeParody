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

from django.db import models
from datetime import datetime, timedelta
from gamecenter import gamecenter_pb2

IDLE_TIME = timedelta(0, 90)

# Create your models here.

class Room(models.Model):
  roomName = models.CharField(max_length=30)
  totalSeats = models.IntegerField(default=4)

  def getNumberOfUsers(self):
    return Game.objects.filter(room__id__exact=self.id).count()
  
  def getGameUsers(self):
    return Game.objects.filter(room__id__exact=self.id)

  def isSeatAvailable(self):
    userList = Game.objects.filter(room__id__exact=self.id)
    numOfUser = userList.count()
    # remove inactive users
    for gu in userList:
      if gu.isInactive():
        print "Kicking user %s" % gu.user.userName
        gu.delete()
        numOfUser-=1

    if numOfUser < self.totalSeats:
      return True
    else:
      return False

  def addUser(self, userId):
    # find the available seat
    seat = self.getAvailableSeatNo()
    
    if seat > 0:
      # if user is in other game before, delete it first
      oldGame = Game.objects.filter(user__id__exact=userId)
      if oldGame:
        for g in oldGame:
          print 'delete user existence in previous room: %d %s' % (g.room.id, g.room.roomName)
          g.delete()
        
      gameUser = Game()
      gameUser.room = self
      gameUser.user = User.objects.get(id=userId)
      gameUser.seat_no = seat
      gameUser.points = 0
      gameUser.time = 0
      gameUser.status = gamecenter_pb2.User.JOINED # from gamecenter_pb2
      gameUser.lastUpdateTime = datetime.now()
      gameUser.save()
    else:
      print "failed to insert user"

  def getAvailableSeatNo(self):
    for i in range(1, self.totalSeats+1):
      if not Game.objects.filter(room__id__exact=self.id, seat_no=i):
        return i

    return 0

  def isUserInRoom(self, userId):
    return Game.objects.filter(user__id__exact=userId, room__id__exact=self.id)

class User(models.Model):
  userName = models.CharField(max_length=30)
  # no password provided in this test
  
  def getGameRoom(self):
    return Game.objects.filter(user__id__exact=self.id)

  def clearRoomSeat(self):
    for g in Game.objects.filter(user__id__exact=self.id):
      g.delete()

class Game(models.Model):
  room = models.ForeignKey(Room)
  user = models.ForeignKey(User)
  seat_no = models.IntegerField()
  points = models.IntegerField()
  time = models.IntegerField()
  status = models.IntegerField()
  lastUpdateTime = models.DateTimeField()

  def isInactive(self):
    if datetime.now() - self.lastUpdateTime > IDLE_TIME:
      print "user(%d, %s) is idle" % (self.user.id, self.user.userName)
      return True
    return False


