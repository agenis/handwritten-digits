train <- data.matrix(read.csv("train.csv", header=T))
test <- data.matrix(read.csv("test.csv", header=T)) 
barplot(table(train[,1]), col=rainbow(10, 0.5), main="n Digits in Train")

plotTrain <- function(images){
  op <- par(no.readonly=TRUE)
  x <- ceiling(sqrt(length(images)))
  par(mfrow=c(x, x), mar=c(.1, .1, .1, .1))
  
  for (i in images){ #reverse and transpose each matrix to rotate images
    m <- matrix(train[i,-1], nrow=28, byrow=TRUE)
    m <- apply(m, 2, rev)
    image(t(m), col=grey.colors(255), axes=FALSE)
    text(0.05, 0.2, col="white", cex=1.2, train[i, 1])
  }
  par(op) #reset the original graphics parameters
}
plotTrain(1:36)
set.seed(1); keep = sample(1:nrow(train), 42000)
train.x <- train[keep, -1] #remove 'label' column
train.y <- train[keep, 1] #label column 
train.x <- t(train.x/255)
test.x <- t(test/255)

m1.data <- mx.symbol.Variable("data") # Notice how each layer is passed to the next 

m1.fc1 <- mx.symbol.FullyConnected(m1.data, name="fc1", num_hidden=128)
m1.act1 <- mx.symbol.Activation(m1.fc1, name="activation1", act_type="relu")

m1.fc2 <- mx.symbol.FullyConnected(m1.act1, name="fc2", num_hidden=64)
m1.act2 <- mx.symbol.Activation(m1.fc2, name="activation2", act_type="relu")

m1.fc3 <- mx.symbol.FullyConnected(m1.act2, name="fc3", num_hidden=10)
m1.softmax <- mx.symbol.SoftmaxOutput(m1.fc3, name="softMax")

graph.viz(m1.softmax)

log <- mx.metric.logger$new() #to keep track of the results each iterration
tick <- proc.time() #mark the start time
mx.set.seed(10)

m1 <- mx.model.FeedForward.create(m1.softmax,  #the network configuration made above
                                  X = train.x, #the predictors
                                  y = train.y, #the labels
                                  #ctx = mx.cpu(),
                                  num.round = 50, # The kernel can only handle 1 (I suggest ~50ish to start)
                                  array.batch.size = 500,
                                  array.layout="colmajor",
                                  learning.rate = 0.001,
                                  momentum = 0.95,
                                  eval.metric = mx.metric.accuracy,
                                  initializer = mx.init.uniform(0.07),
                                  epoch.end.callback = mx.callback.log.train.metric(1,log)
)
# save(m1, file="model_m1.Rdata")
print(paste("Training took:", round((proc.time() - tick)[3],2),"seconds"))
plot(log$train, type="l", col="red", xlab="Iteration", ylab="Accuracy")
m1.preds <- predict(m1, test.x, array.layout = "colmajor")
t(round(m1.preds[,1:5], 2))
m1.preds.value <- max.col(t(m1.preds)) - 1
m1.preds.value[1:5]
plotResults <- function(images, preds){
  op <- par(no.readonly=TRUE)
  x <- ceiling(sqrt(length(images)))
  par(mfrow=c(x,x), mar=c(.1,.1,.1,.1))
  
  for (i in images){
    m <- matrix(test[i,], nrow=28, byrow=TRUE)
    m <- apply(m, 2, rev)
    image(t(m), col=grey.colors(255), axes=FALSE)
    text(0.05,0.1,col="red", cex=1.2, preds[i])
  }
  par(op)
}
plotResults(1:36, m1.preds.value)



# transform points to image
png("out.png")
plot(x=vals$x, y=vals$y, xlim=c(0, 28), ylim=c(0, 28), ylab="y", xlab="x", type="l", lwd=18)
dev.off()
img <- read.pnm("out.png")
imagedata("out.png", type="grey")


library(png)
library(colorspace)
library(cowplot)
par(mar=c(4,4,4,4))

load("out.Rdata")
vals=out
png("out.png", width=28, height=28, bg="white")

qplot(x=vals$x, y=vals$y, geom='path', size=1) + xlim(0, 28) + ylim(0,28) + theme_nothing()
dev.off()
library(EBImage)
extract.matrix = function(z) z@.Data[,,1]
x = "out.png" %>%
  readImage %>%
  gblur(sigma=10) %>%
  resize(w=28, h=28) %>%
  extract.matrix %>%
  # t %>%
  as.vector %>%
  matrix(ncol=1) %>%
  round(2)
# Show(t(matrix(x, ncol=28)))
which.max(predict(m1, x, array.layout = "colmajor"))-1
test.array <- x
dim(test.array) <- c(28, 28, 1, ncol(x))
which.max(predict(m2, test.array))-1

m1.preds <- predict(m1, x, array.layout = "colmajor")
t(round(m1.preds, 2))
m1.preds.value <- max.col(t(m1.preds)) - 1
m1.preds.value[1:5]

test.array <- x
dim(test.array) <- c(28, 28, 1, ncol(x))
predict(m2, test.array)
which.max(predict(m2, test.array))-1

####### export google sheet as folder of pngs
for (i in 1:nrow(temp)) {
  png(sprintf("vignette_%03d.png", i))
  m <- matrix(as.matrix(temp[i,-1]), nrow=28, byrow=TRUE)
  m <- apply(m, 2, rev)
  image(t(m), col=grey.colors(255), axes=FALSE)
  dev.off()
}

##############??? CUSTOM MODEL
gsheet <- "retrieve_shinyhandwriting_training"
sheet <- gs_title(gsheet)
temp <- data.frame(gs_read_csv(sheet)) # %>% mutate(label=as.character(label))
library(mxnet); set.seed(123)
train.indices = sample(nrow(temp), 190)
train = temp %>% slice( train.indices) %>% data.matrix
test  = temp %>% slice(-train.indices) %>% select(-1) %>% data.matrix
barplot(table(train[,1]), col=rainbow(10, 0.5), main="n Digits in Train")
train.x <- train[, -1] #remove 'label' column
train.y <- train[, 1] #label column 
train.x <- t(train.x/1)
test.x <- t(test/1)
m1.data <- mx.symbol.Variable("data") # Notice how each layer is passed to the next 
m1.fc1 <- mx.symbol.FullyConnected(m1.data, name="fc1", num_hidden=128)
m1.act1 <- mx.symbol.Activation(m1.fc1, name="activation1", act_type="relu")
m1.fc2 <- mx.symbol.FullyConnected(m1.act1, name="fc2", num_hidden=64)
m1.act2 <- mx.symbol.Activation(m1.fc2, name="activation2", act_type="relu")
m1.fc3 <- mx.symbol.FullyConnected(m1.act2, name="fc3", num_hidden=10)
m1.softmax <- mx.symbol.SoftmaxOutput(m1.fc3, name="softMax")
graph.viz(m1.softmax)
log <- mx.metric.logger$new() #to keep track of the results each iterration
mx.set.seed(10)
m1 <- mx.model.FeedForward.create(m1.softmax,  #the network configuration made above
                                  X = train.x, #the predictors
                                  y = train.y, #the labels
                                  #ctx = mx.cpu(),
                                  num.round = 1000, # The kernel can only handle 1 (I suggest ~50ish to start)
                                  array.batch.size = 100,
                                  array.layout="colmajor",
                                  learning.rate = 0.001,
                                  momentum = 0.95,
                                  eval.metric = mx.metric.accuracy,
                                  initializer = mx.init.uniform(0.07),
                                  epoch.end.callback = mx.callback.log.train.metric(1,log))
m1.preds <- predict(m1, test.x, array.layout = "colmajor")
t(round(m1.preds[,1:5], 2))
m1.preds.value <- max.col(t(m1.preds)) - 1
m1.preds.value[1:5]
plotResults(1:10, m1.preds.value)
# 2-CONV net
# 1st convolutional layer
m2.data <- mx.symbol.Variable("data")
m2.conv1 <- mx.symbol.Convolution(m2.data, kernel=c(5,5), num_filter=16)
m2.bn1 <- mx.symbol.BatchNorm(m2.conv1)
m2.act1 <- mx.symbol.Activation(m2.bn1, act_type="relu")
m2.pool1 <- mx.symbol.Pooling(m2.act1, pool_type="max", kernel=c(2,2), stride=c(2,2))
m2.drop1 <- mx.symbol.Dropout(m2.pool1, p=0.5)
m2.conv2 <- mx.symbol.Convolution(m2.drop1, kernel=c(3,3), num_filter=32)
m2.bn2 <- mx.symbol.BatchNorm(m2.conv2)
m2.act2 <- mx.symbol.Activation(m2.bn2, act_type="relu")
m2.pool2 <- mx.symbol.Pooling(m2.act2, pool_type="max", kernel=c(2,2), stride=c(2,2))
m2.drop2 <- mx.symbol.Dropout(m2.pool2, p=0.5)
m2.flatten <- mx.symbol.Flatten(m2.drop2)
m2.fc1 <- mx.symbol.FullyConnected(m2.flatten, num_hidden=1024)
m2.act3 <- mx.symbol.Activation(m2.fc1, act_type="relu")
m2.fc2 <- mx.symbol.FullyConnected(m2.act3, num_hidden=512)
m2.act4 <- mx.symbol.Activation(m2.fc2, act_type="relu")
m2.fc3 <- mx.symbol.FullyConnected(m2.act4, num_hidden=256)
m2.act5 <- mx.symbol.Activation(m2.fc3, act_type="relu")
m2.fc4 <- mx.symbol.FullyConnected(m2.act5, num_hidden=10)
m2.softmax <- mx.symbol.SoftmaxOutput(m2.fc4)
train.array <- train.x
dim(train.array) <- c(28, 28, 1, ncol(train.x))
test.array <- test.x
dim(test.array) <- c(28, 28, 1, ncol(test.x))
log <- mx.metric.logger$new() 
mx.set.seed(0)
m2 <- mx.model.FeedForward.create(m2.softmax, 
                                  X = train.array, 
                                  y = train.y,
                                  num.round = 100, # This many will take a couple of hours on a CPU
                                  array.batch.size = 50,
                                  array.layout="colmajor",
                                  learning.rate = 0.001,
                                  momentum = 0.91,
                                  wd = 0.00001,
                                  eval.metric = mx.metric.accuracy,
                                  initializer = mx.init.uniform(0.07),
                                  epoch.end.callback = mx.callback.log.train.metric(1, log))
m2.preds <- predict(m2, test.array)
m2.preds.value <- max.col(t(m2.preds)) - 1
plotResults(1:40, m2.preds.value)
sum(diag(res))/length(m2.preds.value) # accuracy
table(m2.preds.value, temp %>% slice(-train.indices) %>% pull(label))






# to install mxnet
cran <- getOption("repos")
cran["dmlc"] <- "https://s3-us-west-2.amazonaws.com/apache-mxnet/R/CRAN/"
cran = structure(c("https://cran.rstudio.com/", "http://www.stats.ox.ac.uk/pub/RWin", 
                   "https://s3-us-west-2.amazonaws.com/apache-mxnet/R/CRAN/"), .Names = c("CRAN", 
                                                                                          "CRANextra", "dmlc"), RStudio = TRUE)

install.packages("mxnet", repos="cran")

########## avec H20
temp <- data.frame(gs_read_csv(sheet)) %>% mutate(label=factor(label))
set.seed(123)
train.indices = sample(nrow(temp), 190)
train = temp %>% slice( train.indices)
test  = temp %>% slice(-train.indices)

library(h2o)
localH2O =  h2o.init(nthreads = -1, port = 54321, startH2O = FALSE)
as.h2o(train)
as.h2o(test)
NN_model = h2o.deeplearning(
  x=2:785, y=1,
  training_frame = "train",
  hidden = c(400, 200, 2, 200, 400 ),
  epochs = 100,
  activation = "MaxoutWithDropout"
)
h2o.confusionMatrix(NN_model)


