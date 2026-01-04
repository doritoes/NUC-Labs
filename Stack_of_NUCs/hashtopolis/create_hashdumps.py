"""
Create example shadow files and pwdump files for testing

pip install passlib
"""
from passlib.hash import sha512_crypt, nthash

# Input Data
data = [
    ("Lion", "Butterfly123!"),
    ("Tiger", "returnofthejedi"),
    ("Bear", "J@sonHouse"),
    ("Wolf", "sillywombat11"),
    ("Fox", "mi$tyHelp55"),
    ("Otter", "January2022"),
    ("Eagle", "P@$$w0rd"),
    ("Shark", "Ewug4"),
    ("Panda", "ieMuth6"),
    ("Falcon", "covidsucks")
]

def generate_shadow_line(user, password):
    """ create example shadow file line """
    # Passlib handles the rounds and salt generation automatically
    # Ubuntu 24.04 uses 656,000 rounds by default, but standard $6$ works fine for testing
    shadow_hash = sha512_crypt.hash(password)
    return f"{user.lower()}:{shadow_hash}:20386:0:99999:7:::"

def generate_pwdump_line(user, password, uid):
    # nthash is the library's implementation of NTLM
    ntlm = nthash.hash(password).upper()
    lm_empty = "aad3b435b51404eeaad3b435b51404ee"
    return f"{user}:{uid}:{lm_empty}:{ntlm}:::"

# Execution
shadow_output = []
pwdump_output = []
start_uid = 1001

for i, (user, password) in enumerate(data):
    shadow_output.append(generate_shadow_line(user, password))
    pwdump_output.append(generate_pwdump_line(user, password, start_uid + i))

print("--- SHADOW FILE CONTENT ---")
print("\n".join(shadow_output))
print("\n--- PWDUMP FILE CONTENT ---")
print("\n".join(pwdump_output))
