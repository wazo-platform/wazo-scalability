# -*- coding: UTF-8 -*-

## global configuration

sipp_remote_host = 'skaro-load'

sipp_local_ip = '192.168.32.241'
sipp_call_rate = 1.0
sipp_rate_period_in_ms = 1000
#sipp_max_simult_calls = 3
#sipp_nb_of_calls_before_exit = 4
#sipp_background = False
#sipp_enable_trace_calldebug = True
#sipp_enable_trace_err = True
#sipp_enable_trace_shortmsg = True
#sipp_enable_trace_stat = True


## global scenarios configuration

bind_port = 5060

calling_line = {
    'username': 'loadtester',
    'password': 'loadtester',
}

pause = {
    'distribution': 'fixed',
    'value': 5000,
}
#pause = {
#    'distribution': 'uniform',
#    'min': 3000,
#    'max': 7000,
#}
#pause = {
#    'distribution': 'normal',
#    'mean': 5000,
#    'stdev': 1000,
#}

codec = {
	'name': 'ulaw',
	'pt': 0,
	'rtpmap': '0 PCMU/8000',
}
#codec = {
#	'name': 'alaw',
#	'pt': 8,
#	'rtpmap': '8 PCMA/8000',
#}

rtp = 'test3s'
#rtp = 'silence600s'


## scenarios configuration

scenarios.answer_then_hangup = dict(
    bind_port = bind_port,
    ring_time = pause,
    talk_time = pause,
    codec = codec,
    rtp = rtp,
)

scenarios.answer_then_wait = dict(
    bind_port = bind_port,
    ring_time = pause,
    codec = codec,
    rtp = rtp,
)

scenarios.call_then_cancel_on_ringing = dict(
    bind_port = bind_port,
    calling_line = calling_line,
    called_extens = ['1001'],
    ring_time = pause,
)

scenarios.call_then_hangup = dict(
    bind_port = bind_port,
    calling_line = calling_line,
    called_extens = ['1001'],
    talk_time = pause,
    codec = codec,
    rtp = rtp,
)

scenarios.call_then_wait = dict(
    bind_port = bind_port,
    calling_line = calling_line,
    called_extens = ['1001'],
    codec = codec,
    rtp = rtp,
)

scenarios.call_then_wait_decline = dict(
    bind_port = bind_port,
    calling_line = calling_line,
    called_extens = ['1001'],
    codec = codec,
)

scenarios.call_then_wait_tel = dict(
    bind_port = bind_port,
    request_uri = 'tel:+1001',
    from_uri = '<tel:1234;phone-context=+555>',
    to_uri = '<sip:1@example.org>',
    contact_uri = '<sip:+5551234@[local_ip]:[local_port]>',
    # in this scenario, calling_line is used for authentication only
    calling_line = calling_line,
)

scenarios.send_sip_register = dict(
    lines = [
