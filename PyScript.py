import urllib.request
url="https://raw.githubusercontent.com/asanborn/PADDLE/main/paddle.py"
filename, headers = urllib.request.urlretrieve(url, filename="/WYFL-tADs/paddle.py")

#Download directory with model files
PADDLEnoSS=PADDLE_noSS()

#PADDLEnoSS.predict() requires a sequence (or list of sequences) that are all 53 residues long
#Load background sequences
bgseqfile=open("bgseqs.txt")
bgseqs=bgseqfile.read().splitlines()

#Background sequences PADDLE
PADDLEnoSS.predict(seqs=bgseqs)
#output array([-0.07428408, -0.09534788, -0.14848256, -0.08471394, -0.09327412,-0.1096344 , -0.06076264, -0.13757277, -0.10618091, -0.13550806, -0.12573433, -0.09900403, -0.1266737 , -0.15505672, -0.12895942, -0.09975958, -0.11005211, -0.13510418, -0.04616189, -0.11402059], dtype=float32)

#Control sequences PADDLE      
PADDLEnoSS.predict_subsequences(["WDWDWDWDWD","DDDWWWWWDD"],bg_prots=bgseqs)
#output array([6.536373 , 7.3064566], dtype=float32)

#Analyze Entire Library of sequences (Unique sequences w/o stop codon sequences)
PADDLEnoSS=PADDLE_noSS()
AllSeqFile=open("UniqueSeqWholeLibrary.txt")
AllSeq=AllSeqFile.read().splitlines()
AllSeqFile.close()
bgseqfile=open("bgseqs.txt")
bgseqs=bgseqfile.read().splitlines()
bgseqfile.close()
AllSeqPredict=PADDLEnoSS.predict_subsequences(seqs=AllSeq,bg_prots=bgseqs)
count=0
AllSeqOutFile=open("UniqueSeqPADDLEOUT.txt","w")
for i in AllSeqPredict:
  AllSeqOutFile.write(AllSeq[count]+"\t"+str(i)+"\n")
  count+=1
AllSeqOutFile.close()
