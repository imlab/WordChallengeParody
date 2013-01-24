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

from django.conf.urls.defaults import *
from django.views.generic.simple import direct_to_template
import settings, os

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

urlpatterns = patterns('',
    url(r'^$', direct_to_template, {'template': 'index.html'}),
    
    url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': os.path.join(settings.USER_STATIC_ROOT, 'static')}),
    # Uncomment the admin/doc line below to enable admin documentation:
    url(r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    url(r'^admin/', include(admin.site.urls)),

    url(r'^pbauth/', include('pbauth.urls')),
    url(r'^gamecenter/', include('gamecenter.urls')),
)

