{
   "firstname": "User",
   "lastname": "__SEQUENCE__",
   "email": "user__SEQUENCE__@wazo.io",
   "timezone": null,
   "language": null,
   "description": null,
   "caller_id": "\"User __SEQUENCE__\"",
   "outgoing_caller_id": "default",
   "mobile_phone_number": null,
   "username": null,
   "password": null,
   "music_on_hold": null,
   "preprocess_subroutine": null,
   "userfield": null,
   "call_transfer_enabled": false,
   "dtmf_hangup_enabled": false,
   "call_record_outgoing_external_enabled": false,
   "call_record_outgoing_internal_enabled": false,
   "call_record_incoming_internal_enabled": false,
   "call_record_incoming_external_enabled": false,
   "online_call_record_enabled": false,
   "supervision_enabled": true,
   "ring_seconds": 30,
   "simultaneous_calls": 5,
   "call_permission_password": null,
   "subscription_type": 1,
   "enabled": true,
   "call_permissions": [],
   "auth": {
      "username": "pcm+user__SEQUENCE__@wazo.io",
      "password": "secret"
   },
   "fallbacks": {
     "noanswer_destination": null,
     "busy_destination": null,
     "congestion_destination": null,
     "fail_destination": null
   },
   "groups": [],
   "incalls": [
    {
      "extensions": [
        {
          "exten": "__INCALL_PREFIX____EXTENSION__",
          "context": "__INCALL_CONTEXT__"
        }
      ]
    }
   ],
   "lines": [
     {
       "context": "__CONTEXT__",
       "endpoint_sip": {
         "label": "__EXTENSION__",
         "name": "__EXTENSION__",
         "templates": [{"uuid": "__WEBRTC_UUID__"}],
         "auth_section_options": [
           ["username", "__EXTENSION__"],
           ["password", "__EXTENSION__"]
         ]
       },
       "extensions": [{"exten": "__EXTENSION__"}]
     }
   ],
   "forwards": {
     "busy": {
       "enabled": false,
       "destination": null
     },
     "noanswer": {
       "enabled": false,
       "destination": null
     },
     "unconditional": {
       "enabled": false,
       "destination": null
     }
   },
   "schedules": [],
   "services": {
     "dnd": {
       "enabled": false
     },
     "incallfilter": {
       "enabled": false
     }
   },
   "switchboards": [],
   "voicemail": {
    "number": "__EXTENSION__",
    "context": "__CONTEXT__",
    "enabled": true
   },
   "queues": [],
   "func_key_template_id": null,
   "call_pickup_target_users": []
 }
