import json
from msa_sdk.variables import Variables
from msa_sdk.msa_api import MSA_API
from msa_sdk.lookup import Lookup
from msa_sdk.device import Device

# Admit user-input variables
dev_var = Variables()
dev_var.add('subtenant', var_type='Customer')
dev_var.add('device', var_type='Device')
context = Variables.task_call(dev_var)

# Collect device (IDs,manufacturer) and pass the to context 
me_list = []

# Assume device specified if no subtenant mentioned
if len(context['subtenant']) == 0:
    did = context['device'][-3:]
    device = Device(device_id=did)
    me_list.append(did)
    name = device.name

# Assume subtenant specified, no matter if device mentioned or not
elif len(context['subtenant']) > 0:
    search = Lookup()
    search.look_list_device_by_customer_ref(context['subtenant'])
    device_list = search.content.decode()
    device_list = json.loads(device_list)
    name = 'Entire Perimeter'

    for device in device_list:
        me_list.append((device['id'],
                               Device(device_id=device['id']).manufacturer_id))

# Neither device nor subtenant specified
else:
    ret = MSA_API.process_content('FAILED',
                                  'Nothing to protect, \
                                  no domain neither device specified.',
                                  context, True)
    print(ret)
    exit()

# Pass data to context
context['me_list'] = me_list
# Create named WF instances instead of auto-incremental
context['NAME'] = name

ret = MSA_API.process_content('ENDED',
                              f'WF initialized - \
                              Perimeter defined \
                              {context["me_list"]}',
                              context, True)
print(ret)
