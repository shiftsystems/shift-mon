set dotenv-load
extra-args := "-K"
limit := "all"

shiftmon:
  ansible-playbook -i $INVENTORY -l {{ limit }} {{ extra-args }} shiftmon.yml 
telegraf:
  ansible-playbook -i $INVENTORY -l {{ limit }} {{ extra-args }} telegraf.yml 

