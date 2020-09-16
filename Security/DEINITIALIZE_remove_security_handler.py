from msa_sdk.variables import Variables
from msa_sdk.msa_api import MSA_API
from msa_sdk.order import Order

dev_var = Variables()
context = Variables.task_call()

ret = MSA_API.process_content('ENDED', 'Security handler removed.', context, True)

print(ret)
