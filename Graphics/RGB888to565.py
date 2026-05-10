
with open("SkaraBrae.rgb", mode="rb") as f_in:
    conts = f_in.read()
    
with open("SkaraBrae.rgb", mode="wb") as f_out:
    
    for i in range(0x10000):
        r = conts[3*i] // 8
        g = conts[3*i+1] // 4
        b = conts[3*i+2] // 8

        col = (r << 11) + (g << 5) + b
        col_hi = (col & 0xff00) >> 8
        col_lo = col & 0x00ff
        
        f_out.write(col_hi.to_bytes(1, 'big'))
        f_out.write(col_lo.to_bytes(1, 'big'))
