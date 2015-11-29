from flask import Flask
from flask_pushjack import FlaskAPNS

config = {
            'APNS_CERTIFICATE': 'push_dev.pem'
            }

app = Flask(__name__)
app.config.update(config)

client = FlaskAPNS()
client.init_app(app)

with app.app_context():
        token = 'afb5c4ff3c153dbe30a3a04ee168030f5b5d786035f629779ad999af3786a697'
        # Send to single device.
        res = client.send(token, alert, **options)
        # List of all tokens sent.
        res.tokens
        
        # List of any subclassed APNSServerError objects.
        res.errors
        
        # Dict mapping token => APNSServerError.
        res.token_errors
        
        # Send to multiple devices.
        client.send([token], alert, **options)
        
        # Get expired tokens.
        expired_tokens = client.get_expired_tokens()
