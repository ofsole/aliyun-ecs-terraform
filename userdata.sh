#!/bin/sh

yum install -y python-devel
pip install aliyun-python-sdk-ecs

tee /tmp/ecs.py <<-'EOF'
import socket
import requests
from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.request import RpcRequest
from aliyunsdkcore.acs_exception.exceptions import ClientException
from aliyunsdkcore.acs_exception.exceptions import ServerException
from aliyunsdkecs.request.v20140526 import ModifyInstanceAttributeRequest
client = AcsClient(
    "access_key", 
    "security_token",
    "cn-shanghai"
);

r = socket.gethostname()
req = requests.get('http://100.100.100.200/latest/meta-data/instance-id')
request = ModifyInstanceAttributeRequest.ModifyInstanceAttributeRequest()
request.set_InstanceId(req.text)
request.set_InstanceName(r)
response = client.do_action_with_exception(request)
print response
EOF

#python /tmp/ecs.py

ACCESS_KEY_ID=access_key
ACCESS_KEY_SECRET=access_key
REGION=cn-shanghai
curl -L 'http://aliacs-k8s.oss-cn-hangzhou.aliyuncs.com/installer/kubemgr.sh' | \
            bash -s nice --node-type master --key-id $ACCESS_KEY_ID --key-secret $ACCESS_KEY_SECRET \
                --region $REGION --discovery token://
