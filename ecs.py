import socket
from aliyunsdkcore.client import AcsClient
from aliyunsdkcore.request import RpcRequest
from aliyunsdkcore.acs_exception.exceptions import ClientException
from aliyunsdkcore.acs_exception.exceptions import ServerException
from aliyunsdkecs.request.v20140526 import ModifyInstanceAttributeRequest
client = AcsClient(
    "accesskey", 
    "token",
    "cn-shanghai"
);

#r = requests.get('http://100.100.100.200/latest/meta-data/instance-id')
r = socket.gethostname()
request = ModifyInstanceAttributeRequest.ModifyInstanceAttributeRequest()
request.set_InstanceName(r)
#request.set_InstanceId(r.text)
response = client.do_action_with_exception(request)
print response
