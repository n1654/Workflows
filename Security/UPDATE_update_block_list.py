from msa_sdk.variables import Variables
from msa_sdk.msa_api import MSA_API
from msa_sdk.order import Order

# Admit user input variables
dev_var = Variables()
dev_var.add('prefix', var_type='String')
dev_var.add('action', var_type='String')
context = Variables.task_call(dev_var)

# Need to convert object name eg. host-1.2.3.4 to
# msa compatible host-1_2_3_4
def convert_to_id(name):
    return name.replace(".", "_")

# Work Around function http://jira.ubiqube.com/browse/MSA-8824
def wa(dictionary):
    correct_list = []
    for i in dictionary.keys():
        correct_list.append((dictionary[i]['0'], dictionary[i]['1']))
    return correct_list

#######################################
#    (1) Microservice Preparation     #
#######################################

asa_ms_add_obj = {"asa_sec_object_host": {
                    'host-' + convert_to_id(context['prefix']): {
                        "object_id":
                            'host-' + context['prefix'],
                            "ip_address": context['prefix']
                         }
                     }
                  }

asa_ms_del_obj = {"asa_sec_object_host":
                  'host-' + convert_to_id(context['prefix'])}

asa_ms_add_rule = {"asa_sec_block_list": {
                     'host-' + convert_to_id(context['prefix']): {
                          "object_id": 'host-' + context['prefix']
                          }
                      }
                   }

asa_ms_del_rule = {"asa_sec_block_list":
                   'host-' + convert_to_id(context['prefix'])}

vsrx_ms_add = {"vsrx_sec_block_list": {
                  'host-' + convert_to_id(context['prefix']): {
                      "object_id": context['prefix']
                      }
                   }
               }

vsrx_ms_del = {"vsrx_sec_block_list":
                'host-' + convert_to_id(context['prefix'])}

linux_ms_add = {"linux_sec_block_list": {
                  'host-' + convert_to_id(context['prefix']): {
                      "object_id": context['prefix']
                      }
                   }
               }

linux_ms_del = {"linux_sec_block_list":
                'host-' + convert_to_id(context['prefix'])}

context['asa_ms_add_obj'] = asa_ms_add_obj
context['asa_ms_del_obj'] = asa_ms_del_obj
context['asa_ms_add_rule'] = asa_ms_add_rule
context['asa_ms_del_rule'] = asa_ms_del_rule
context['vsrx_ms_add'] = vsrx_ms_add
context['vsrx_ms_del'] = vsrx_ms_del
context['linux_ms_add'] = linux_ms_add
context['linux_ms_del'] = linux_ms_del

#######################################
#    (2) Microservice Execution       #
#######################################

# Define microservice method to execute
# as well as and microservice data
def action(value, ms_add, ms_del):
    if value == 'ADD':
        return "CREATE", ms_add
    elif value == 'REMOVE':
        return "DELETE", ms_del
    else:
        exit()


context['me_list'] = wa(context['me_list'])

# Execute microservices
for me in context['me_list']:
    # cisco asa
    if me[1] == '1':
        order = Order(me[0])
        # create object
        act = action(context['action'],
                     context['asa_ms_add_obj'],
                     context['asa_ms_del_obj'])
        order.command_execute(act[0], act[1])
        # add/delete object to/from block-list
        act = action(context['action'],
                     context['asa_ms_add_rule'],
                     context['asa_ms_del_rule'])
        order.command_execute(act[0], act[1])
        # delete object
        act = action(context['action'],
                     context['asa_ms_add_obj'],
                     context['asa_ms_del_obj'])
        order.command_execute(act[0], act[1])
    # juniper vsrx
    elif me[1] == '18':
        order = Order(me[0])
        act = action(context['action'],
                     context['vsrx_ms_add'],
                     context['vsrx_ms_del'])
        order.command_execute(act[0], act[1])
    # linux
    elif me[1] == '14020601':
        order = Order(me[0])
        act = action(context['action'],
                     context['linux_ms_add'],
                     context['linux_ms_del'])
        order.command_execute(act[0], act[1])
    else:
        exit()


# Create appropriate message to print out
if context['action'] == 'ADD':
    message = f'Prefix {context["prefix"]} added to the BLOCK-LIST. \
              Perimeter updated.'
else:
    message = f'Prefix {context["prefix"]} removed from the BLOCK-LIST. \
              Perimeter updated.'

ret = MSA_API.process_content('ENDED',
                              message,
                              context, True)
print(ret)
