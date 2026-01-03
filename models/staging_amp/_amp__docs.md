-------------------------location----------------------

{%docs location_sk_id %}

sk with ip address, city, country, region

{% enddocs %}

{%docs ip_address %}

the primary key of int_amp__locations table

{% enddocs %}

-------------------------users----------------------

{%docs amplitude_id %}

the primary key of int_amp__users table. maps 1:1 to user

{% enddocs %}

{%docs user_id %}

contains email address if exists.

{% enddocs %}

{%docs company %}

organization derived from email address

{% enddocs %}

-------------------------events----------------------

{%docs event_sk_id %}

surrogated primary key based on session id, event id, amplitude id, and device id

{% enddocs %}

{%docs row_number %}

unique identifer per session and event. used to de-duplicate events table

{% enddocs %}

{%docs session_id %}

id for session. a session is assigned each time a user lands on TIL website.

{% enddocs %}

{%docs event_id %}

per session, each user action is assigned an event id. 

{% enddocs %}

{%docs event_time %}

may not be within range of API pull request dates. may need to investigate further

{% enddocs %}

{%docs client_upload_time %}

used to de-duplicate repeating event ids within sessions

{% enddocs %}

{%docs extract_time %}

when amplitude API was called. used in incremental strategy

{% enddocs %}

{%docs event_type %}

category for each event id. can be following values:

The type of event captured in the system. One of the following values:

| Event Type | Meaning |
|:-----------|:--------|
| Activate Modal Search | User opens or activates a modal search interface. |
| [Amplitude] Element Changed | User modifies an interactive element (like input fields) tracked by Amplitude. |
| [Amplitude] Element Clicked | User clicks an interactive element tracked in Amplitude. |
| [Amplitude] File Downloaded | User downloads a file tracked in Amplitude. |
| [Amplitude] Form Started | User begins filling out a form tracked in Amplitude. |
| [Amplitude] Form Submitted | User submits a form tracked in Amplitude. |
| [Amplitude] Page Viewed | User views a page being tracked by Amplitude. |
| [Amplitude] Replay Captured | An event tracking a replay of user actions on the site is captured. |
| Data Skills Video | User interacts with or watches a specific “Data Skills” video. |
| Mailchimp Campaign | User interacts with a Mailchimp email campaign (e.g., opens or clicks). |
| Newsletter Sign Up | User submits their email to subscribe to a newsletter. |
| session_end | Marks the end of a user session on the website or app. |
| session_start | Marks the beginning of a user session on the website or app. |
| video_finished | User watches a video to completion. |
| video_loaded | A video is successfully loaded and ready to play. |
| video_paused | User pauses a video. |
| video_started | User begins playing a video. |

{% enddocs %}