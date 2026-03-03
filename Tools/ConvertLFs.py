
# Convert LF's (Mac) to CRLF's (Windows)

CR = 0x0d

with open('MC.txt', 'rb') as fin:
   conts = fin.read()

with open('MC_H.txt', 'wb') as fout:
   for i in range(len(conts)):
      if conts[i] == 0x0a:
         fout.write(CR.to_bytes(1, 'big'))
      fout.write(conts[i].to_bytes(1, 'big'))
