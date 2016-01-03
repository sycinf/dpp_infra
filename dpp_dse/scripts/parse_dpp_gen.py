__author__ = 'chengs'
import re
import argparse
import os
from glob import glob
import shutil

# we start from one FUNCBEGIN and keep all lines till
# the next FUNCBEGIN
def getPerFuncInfo(inCpp):
    funcName2Everything={}
    pattern = re.compile('\W*FUNCBEGIN:(.*)',re.I)
    fifoSecPattern = re.compile('\W*FIFOBEGIN:(.*)',re.I);
    fifoInfo=[]
    curFuncInfo = []
    prevFuncName = ""
    parsingStarted =  False
    parsingFifoStarted = False
    for line in inCpp:
        line = line.rstrip()
        matchName = pattern.match(line)
        matchFifo = fifoSecPattern.match(line)
        if matchName:
            parsingStarted = True
            parsingFifoStarted = False
            funcName = matchName.group(1)
            if prevFuncName != "":
                prevFuncInfo = curFuncInfo[:]
                funcName2Everything[prevFuncName] = prevFuncInfo
                curFuncInfo=[]
            prevFuncName = funcName
        if parsingStarted:
            curFuncInfo.append(line)

        if matchFifo:
            parsingStarted = False
            parsingFifoStarted = True
        if parsingFifoStarted:
            fifoInfo.append(line)
                        
        # if we see the fifo begin tag, we need to 
    # the last bunch of things
    funcName2Everything[prevFuncName] =  curFuncInfo
    return (funcName2Everything, fifoInfo)
# this we break the info into portions
# #FUNCTCLBEGIN: --- #FUNCTCLEND
#   this is the tcl for generating hls cores
# #DIRECTIVEBEGIN: --- #DIRECTIVEEND:
#   this is the directive tcl for in hls cores
# #DRIVERBEGIN: --- #DRIVEREND:
#   this is the C code for driving the hls cores -- setup function basically
#
def getScriptDriverComponent(lineArray):
    funcContentBegin = re.compile('\W*FUNCBEGIN:(.*)',re.I)
    funcContentEnd = re.compile('\W*FUNCEND:(.*)',re.I)
    funcTclBegin = re.compile('\W*FUNCTCLBEGIN:(.*)',re.I)
    funcTclEnd = re.compile('\W*FUNCTCLEND:(.*)',re.I)
    directiveTclBegin = re.compile('\W*DIRECTIVEBEGIN:(.*)',re.I)
    directiveTclEnd = re.compile('\W*DIRECTIVEEND:(.*)',re.I)
    driverBegin =  re.compile('\W*DRIVERBEGIN:(.*)',re.I)
    driverEnd =  re.compile('\W*DRIVEREND:(.*)',re.I)
    componentName2Content = {}
    funcContent = []
    funcTcl= []
    directiveTcl = []
    driverC = []


    # when this is 1, funcContent
    #              2, funcTcl
    #              3, directiveTcl
    #              4, driverC
    beginPatternMatcher = [funcContentBegin,funcTclBegin,directiveTclBegin,driverBegin];
    endPatternMatcher = [funcContentEnd,funcTclEnd,directiveTclEnd,driverEnd];
    infoBook = [funcContent,funcTcl,directiveTcl,driverC]
    partBeingParsed = 0
    for line in lineArray:
        if partBeingParsed != 0:
            curEndPatternMatcher = endPatternMatcher[partBeingParsed-1]
            if curEndPatternMatcher.match(line):
                partBeingParsed = 0
            else:
                infoBook[partBeingParsed-1].append(line)
        else:
            matcherIndex = 0
            for patternMatcher in beginPatternMatcher:
                if patternMatcher.match(line):
                    break
                matcherIndex += 1
            if matcherIndex != len(beginPatternMatcher):
                partBeingParsed = matcherIndex+1
    componentName2Content['funcContent'] = infoBook[0]
    componentName2Content['funcTcl'] = infoBook[1]
    componentName2Content['directiveTcl'] = infoBook[2]
    componentName2Content['driverC'] = infoBook[3]
    return componentName2Content

def dumpToFile(linesInfo, outfile):
    for line in linesInfo:
        outfile.write(line)
        outfile.write("\n")
def cleanFifoInstantiation(fifoInstantiation):
    cleaned = []
    fifoSecPattern = re.compile('\W*FIFOBEGIN:(.*)',re.I);
    fifoSecPattern2 = re.compile('\W*FIFOEND:(.*)',re.I);
    for line in fifoInstantiation:
        if not (fifoSecPattern.match(line) or fifoSecPattern2.match(line)):
            cleaned.append(line)
    return cleaned
    

def main():
    parser = argparse.ArgumentParser(description='supply filename to parse and the output root dir')
    parser.add_argument('-i', dest='infileName', help='input file name', required=True)
    parser.add_argument('-od', dest='outdirName',help='output directory',required=True)
    args = parser.parse_args()

    inCpp = open(args.infileName,"r")
    outDir = args.outdirName
    funcName2Info,fifoInstantiation = getPerFuncInfo(inCpp)
    fifoInstantiation = cleanFifoInstantiation(fifoInstantiation)
    retDir = os.getcwd()
    os.chdir(outDir)
    toRemove = glob(outDir+'/*')
    for each2Rm in toRemove:
        shutil.rmtree(each2Rm)
    # clear output dir
    vivadoDir = outDir+'/vivado'
    vivadoHLSDir = outDir + '/vivado_hls'
    sdkDir = outDir + '/sdk'
    os.mkdir(vivadoDir)
    os.mkdir(vivadoHLSDir)
    os.mkdir(sdkDir)
    completeDriverFile = open(sdkDir+'/run.h','w')
    # under vivado hls
    topLevelDriver = []
    for key, value in funcName2Info.iteritems():
        print 'for function:', key
        partName2Lines = getScriptDriverComponent(value)
        # now set up the

        functionContent = partName2Lines['funcContent']
        functionTcl = partName2Lines['funcTcl']
        directiveTcl = partName2Lines['directiveTcl']
        driverC = partName2Lines['driverC']
        topLevel = (len(directiveTcl) == 0)
        print topLevel
        curBaseDir = vivadoDir
        if not topLevel:
            os.mkdir(vivadoHLSDir+'/'+key)
            curBaseDir=vivadoHLSDir+'/'+key
        funcTclFile = open(curBaseDir+'/'+'run.tcl','a')
        dumpToFile(functionTcl, funcTclFile)
        if not topLevel:
            directiveTclFile = open(curBaseDir+'/'+'directive.tcl','w')
            dumpToFile(directiveTcl, directiveTclFile)
            funcFile = open(curBaseDir+'/'+key+'.cpp','w')
            funcFile.write("#include \"ap_int.h\"\n")
            dumpToFile(functionContent, funcFile)
            dumpToFile(driverC,completeDriverFile)
        else:
            topLevelDriver.extend(functionContent)
            dumpToFile(fifoInstantiation,funcTclFile)
    dumpToFile(topLevelDriver,completeDriverFile)
    # go into each vivado_hls dir and invoke vivado_hls
    os.chdir(retDir)
    toSynthesize = glob(vivadoHLSDir+'/*')
    for curSyn in toSynthesize:
        os.chdir(curSyn)
        os.system("vivado_hls -f run.tcl")
        os.chdir(retDir)
    print toSynthesize    
            
    print 'done'


if __name__=="__main__":
    main()




