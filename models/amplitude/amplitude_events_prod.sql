with 

dev as (

    select * from {{ ref('amplitude_events_dev') }}

)

select 
	"""amplitude_id""" AS AMPLITUDE_ID,
	"""client_event_time""" AS CLIENT_EVENT_TIME,
	"""country""" AS COUNTRY,
	"""region""" AS REGION,
	"""city""" AS CITY,
	"""event_time""" AS EVENT_TIME,
	"""event_type""" AS EVENT_TYPE,
	"'[Amplitude] Session Replay ID'" AS SESSION_ID,
	"'[Amplitude] Page Counter'" AS PAGE_COUNTER,
	"'[Amplitude] Page Domain'" AS PAGE_DOMAIN,
	"'[Amplitude] Page Location'" AS PAGE_LOCATION,
	"'[Amplitude] Page Path'" AS PAGE_PATH,
	"'[Amplitude] Page Title'" AS PAGE_TITLE,
	"'[Amplitude] Page URL'" AS PAGE_URL,
	"'referring_domain'" AS REFERRING_DOMAIN
from dev