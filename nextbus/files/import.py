import urllib2
import subprocess
from optparse import OptionParser

def grab(url):
   usock = urllib2.urlopen(url)
   data = usock.read()
   usock.close()

   return data

def post(url, data):
   opener = urllib2.build_opener(urllib2.HTTPHandler)
   request = urllib2.Request(url, data)
   request.get_method = lambda: 'PUT'
   url = opener.open(request)
   return

def config():
   p = subprocess.Popen(["php", "/root/nextbus/index.php", "nextbus", "get_config", "rutgers"], stdout=subprocess.PIPE);
   route_config, err = p.communicate()
   post('https://nextbeezy.firebaseio.com/rutgers/config.json?key={{ salt['pillar.get']('nextbus:firebase_key') }}', route_config)

def predictions():
   q = subprocess.Popen(["php", "/root/nextbus/index.php", "nextbus", "get_predictions", "rutgers"], stdout=subprocess.PIPE);
   times, err = q.communicate()
   post('https://nextbeezy.firebaseio.com/rutgers/predictions.json?key={{ salt['pillar.get']('nextbus:firebase_key') }}', times)

parser = OptionParser()
parser.add_option("-p", "--predictions", action="store_true", dest="predictions", default=False, help="Generate predictions.")
parser.add_option("-c", "--config", action="store_true", dest="config", default=False, help="Generate config.")

(options, args) = parser.parse_args()

if options.predictions:
   predictions()

if options.config:
   config()
