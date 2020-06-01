signal list(temparory):
inputs:
    reset           :   Synchronize reset               
    adr             :   address                         
    data_in         :   set selected reg                
    cs              :   chip select                     
    next            :   a pluse to show its a new data

outputs:
    scl             :   scl input
    sda             :   sda input
    scl_oen         :   scl out enable , use three state gate to control in/out
    sda_oen         :   the same as above
    inta            :   intrrupt signal

register:
    TXR             :   [00]    save data to transmit
    RXR             :   [01]    save data recieved
    SR              :   [10]    satte rigister
    CTR             :   [11]    control rigister

rigister details:
    TXR:
        [7:0]: data to transmite
        reset: 8'h00
    RXR:
        [7:0]: data recieved
        reset: 8'h00
    SR:
        [0]:   0:not sending start    1: sending start
        [1]:   0:not sending data     1:sending data
        [2]:   0:not sending end      1:sending end
        [3]:   0:not using bus        1:using bus
        [4]:   0:waiting for ack      1:recieved ack
        [7:5]: reversed
        reset: 8'h00
    CTR:
        [0]:   1:write                0:read
        [1]:   ⬆:start                ⬇:end
        [2]:   1:intrrupt enable      1:intrrupt disable
        [7:3]: reversed
        reset: 8'h00

flags:
    done_start
    done_send
    done_end