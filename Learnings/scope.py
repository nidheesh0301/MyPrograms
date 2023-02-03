def check_scope():
    def do_local():
        test="local"
    def do_non_local():
        nonlocal test
        test="non local"
    def do_global():
        global test
        test="global"
    test="default"
    do_local()
    print("Value of test after do_local:" +test)
    do_non_local()
    print("Value of test after do_non_local:" +test)
    do_global()
    print("Value of test after global:" +test)

check_scope()
print("Value of test after main:" +test)