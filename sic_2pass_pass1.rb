# This program written in ruby 2.3.1 represents the 'pass-1' of '2-pass SIC assembler'.

# Building 'OPTAB' from file
optab=Hash.new
file=File.open("OPTAB.txt")
while line=file.gets
		line=line.split
		optab[line[1]]=line[0]
		end
file.close

# Building 'SYMTAB' from source code and writing intermediate file
symtab=Hash.new
start_check=false
locctr=start_addr=0
source=File.open("source.txt")
intermediate=File.open("intermediate.txt", "w")
while line_org=source.gets
	line=line_org.split
	if line[1]=='START'
		locctr=start_addr=line[2]
		intermediate.puts("\t\t"+line_org)
		start_check=true
		break;
	end
end
if start_check
	while line_org=source.gets
		line=line_org.split
		if line[0]=='END'
			intermediate.puts(line_org)
			break;
		end
		intermediate.puts(locctr.rjust(4,"0")+"\t"+line_org)
		if optab[line[0]]
			locctr=((locctr.to_i(16)+3).to_s(16)).to_s
		elsif line[0]=='WORD'
			locctr=((locctr.to_i(16)+3).to_s(16)).to_s
		elsif line[0]=='RESW'
			locctr=((locctr.to_i(16)+3*line[1].to_i).to_s(16)).to_s
		elsif line[0]=='RESB'
			locctr=((locctr.to_i(16)+line[1].to_i).to_s(16)).to_s
		elsif line[0]=='BYTE'
			if line[1][0]=='C'
				locctr=((locctr.to_i(16)+line[1].length-3).to_s(16)).to_s
			elsif line[1][0]=='X'
				locctr=((locctr.to_i(16)+(line[1].length-3)/2).to_s(16)).to_s
			end	
		elsif symtab[line[0]]
			puts 'duplicate symbol error'
		else
			symtab[line[0]]=locctr.rjust(4,"0")
			if line[1]=='WORD'
				locctr=((locctr.to_i(16)+3).to_s(16)).to_s
			elsif line[1]=='RESW'
				locctr=((locctr.to_i(16)+3*line[2].to_i).to_s(16)).to_s
			elsif line[1]=='RESB'
				locctr=((locctr.to_i(16)+line[2].to_i).to_s(16)).to_s
			elsif line[1]=='BYTE'
				if line[2][0]=='C'
					locctr=((locctr.to_i(16)+line[2].length-3).to_s(16)).to_s
				elsif line[2][0]=='X'
					locctr=((locctr.to_i(16)+(line[2].length-3)/2).to_s(16)).to_s
				end	
			else
				locctr=((locctr.to_i(16)+3).to_s(16)).to_s
			end
		end
	end
end
source.close
intermediate.close

# Writing end value of 'LOCCTR'
LOCCTR=File.open("LOCCTR.txt", "w")
LOCCTR.puts("LOCCTR\t"+locctr)
LOCCTR.close

# Writing 'SYMTAB'
sym_file=File.open("SYMTAB.txt", "w")
symtab.each {|k,v| sym_file.puts("#{k}\t #{v}")}
sym_file.close
