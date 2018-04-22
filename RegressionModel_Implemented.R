#setwd("C:/Users/Xander/Desktop/EarthxHack/Datasets")
pollution=read.csv("pollution_us_2000_2016.csv")
head(pollution)

pollution$yearn<-as.character(pollution$Date.Local)

pollution$year<-substr(pollution$Date.Local,nchar(pollution$year)-3,nchar(pollution$year))

#View(pollution)

#install.packages("plyr")
library(plyr)


#groupColumns = c("State","City","year")
#dataColumns = c("NO2.Mean","O3.Mean","SO2.Mean","CO.Mean")

#filterepollution = ddply(pollution, groupColumns, function(x) colSums(x[dataColumns]))

#View(filterepollution)

#groupColumns2 = c("State","year")

#groupColumns3 = c("year")
#dataColumns2 = c("NO2.Mean","O3.Mean","SO2.Mean","CO.Mean")


#pollutionbystate=ddply(filterepollution, groupColumns2, function(x) colSums(x[dataColumns2]))
#pollutionbyyear=ddply(filterepollution, groupColumns3, function(x) colSums(x[dataColumns2]))


#View(pollutionbystate)
#View(pollutionbyyear)

co2data= read.csv("co2.csv")


#View(co2data)

co2data <- co2data[ -c(13:17) ]

colnames(co2data) <- c("State","2000", "2001","2002","2003","2004","2005","2006","2007","2008","2009","2010")



#co2dataunpivot= write.csv(co2data, file = "co2data.csv")

#install.packages("reshape")
library(reshape)
co22=melt(co2data, id=(c("State")))

#View(co22)

colnames(co22) <- c("State","year","Co2val")


pollutants<-merge(x = pollutionbystate, y = co22, by = c("State","year"), all.x = TRUE)

#View(pollutants)

groupColumns4 = c("year")
dataColumns4 = c("NO2.Mean","O3.Mean","SO2.Mean","CO.Mean","Co2val")

pollutants=na.omit(pollutants)

#View(pollutants)
str(pollutants)
pollutants$Co2val=as.numeric(pollutants$Co2val)

pollutionbyyear=ddply(pollutants, groupColumns4, function(x) colSums(x[dataColumns4]))


#View(pollutionbyyear)

ustemp=read.csv("usatemp.csv")
#View(ustemp)

usprecipitation=read.csv("usaprecipitation.csv")


climate<-merge(x = ustemp, y = usprecipitation, by = c("year"), all.x = TRUE)
#View(climate)

colnames(climate) <- c("year","temp","precipitation")




globalsealevelchange=read.csv("sea-level_fig-1.csv")
#View(globalsealevelchange)




stationsealevel<- read.csv("GlobalStationsLinearSeaLevelTrends.csv")
#View(stationsealevel)

stationsealevel <- stationsealevel[ -c(1,6,8:10) ]



#View(pollutants)
#View(pollutionbyyear)
#View(climate)
#View(globalsealevelchange)
#View(stationsealevel)

tempswithpollutantsyr<-merge(x = pollutionbyyear, y = climate, by = c("year"), all.x = TRUE)
#View(tempswithpollutantsyr)


str(tempswithpollutantsyr)
tempswithpollutantsyr$year<- as.numeric(tempswithpollutantsyr$year)

linearMod <- lm(temp ~ year+NO2.Mean+O3.Mean+SO2.Mean+CO.Mean+Co2val, data=tempswithpollutantsyr) 
summary(linearMod)
str(linearMod)

library(tree)
tree.model <- tree(temp ~ year+NO2.Mean+O3.Mean+SO2.Mean+CO.Mean+Co2val, data=tempswithpollutantsyr)
summary(tree.model)
plot(tree.model)
text(tree.model, cex=.75)

plot(tempswithpollutantsyr$year, tempswithpollutantsyr$Co2val,xlab="Year",ylab="CO2")


linearModNo2 <- lm(NO2.Mean~year, data=tempswithpollutantsyr)
#summary(linearModNo2)
linearModO3 <- lm(O3.Mean~year, data=tempswithpollutantsyr)
#summary(linearModO3)
linearModSO2 <- lm(SO2.Mean~year, data=tempswithpollutantsyr)
#summary(linearModSO2)
linearModCO <- lm(CO.Mean~year, data=tempswithpollutantsyr)
#summary(linearModCO)
linearModco2 <- lm(Co2val~year, data=tempswithpollutantsyr)
#summary(linearModco2)


#year=3172
year=c(year)
newno2<-predict(linearModNo2, newdata, interval="predict") 
NO2.Mean<- c(newno2[1])
newO3<-predict(linearModO3, newdata, interval="predict") 
O3.Mean<-c(newO3[1])
newSO2<-predict(linearModSO2, newdata, interval="predict") 
SO2.Mean<-c(newSO2[1])
newCO<-predict(linearModCO, newdata, interval="predict") 
CO.Mean<-c(newCO[1])
newco2<-predict(linearModco2, newdata, interval="predict") 
Co2val<-c(newco2[1])

finalnewdata<- data.frame(year,NO2.mean,O3.mean,SO2.mean,CO.Mean,CO2val)
str(finalnewdata)
#summary(linearMod)

finalnewtemp<-predict(linearMod, finalnewdata, interval="predict")
finalnewtemp[1]




sea_level_final=read.csv("sea_level_final.csv")
str(sea_level_final)
sea_level_final$Time=as.Date(sea_level_final$Time)
#View(sea_level_final)
sea_level_final$year<-format(as.Date(sea_level_final$Time, format="%d/%m/%Y"),"%Y")

sea_level_changing<- merge(x = sea_level_final, y = climate, by = c("year"), all.x = TRUE)
#View(sea_level_changing)

sea_level_changing<-na.omit(sea_level_changing)
str(sea_level_changing)

plot(sea_level_changing$temp, sea_level_changing$GMSL,xlab="Year",ylab="GMSL")
abline(lm(sea_level_changing$GMSL~sea_level_changing$temp), col="red")

sea_level_changing$year<-as.numeric(sea_level_changing$year)


linearmodelsealevel <- lm(GMSL~year+temp, data=sea_level_changing)
#summary(linearmodelsealevel)

finalnewtemp[1]
year
finalsealevelnewdata<- data.frame(year,finalnewtemp[1])
colnames(finalsealevelnewdata)<- c('year','temp')



newsealevel<-predict(linearmodelsealevel, finalsealevelnewdata, interval="predict")
maxval<-max(sea_level_changing$GMSL)

newsealevel[3]

if(newsealevel[1]<maxval)
{
  newsealevel<-maxval+((newsealevel[3]-newsealevel[1])/2);
}else
{
  newsealevel<-newsealevel[3];
}
  
newsealevel

globalsealevel<-read.csv("GlobalLinearSealevel.csv")
head(globalsealevel)
#View(globalsealevel)

#newsealevel


globalsealevel$city <- gsub(",.*$", "", globalsealevel$Station.Name)

#View(globalsealevel)

globalsealevel$comma<-as.numeric(regexpr(", ",globalsealevel$Station.Name))
globalsealevel$charlength<-as.numeric(nchar(as.character(globalsealevel$Station.Name)))-3

globalsealevel$comma1=globalsealevel$comma+2
globalsealevel$country <- substr(globalsealevel$Station.Name,globalsealevel$comma1,globalsealevel$charlength)


elevation<- read.csv("elevation.csv")
#View(elevation)

globalsealevelwithelevation<-merge(x = globalsealevel, y = elevation, by = c("city","country"), all.x = TRUE)
#View(globalsealevelwithelevation)


yearsprocessed<- year-format(as.Date(Sys.Date(), format="%d/%m/%Y"),"%Y")

finalval<-(elevation*1000-newsealevel)/(yearsprocessed*Absolute.value.of.MSL.Trend)
#finalval<-(14*1000-newsealevel)/(154*8.6675)


if (finalval<1){
  globalsealevel$Drowned<-'Yes'
}else{
  globalsealevel$Drowned<-'No'
}

