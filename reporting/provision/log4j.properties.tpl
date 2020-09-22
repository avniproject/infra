log4j.rootLogger=WARN, file

# log to the console
log4j.appender.console=org.apache.log4j.ConsoleAppender
log4j.appender.console.Target=System.out
log4j.appender.console.layout=org.apache.log4j.PatternLayout
log4j.appender.console.layout.ConversionPattern=%d{MM-dd HH:mm:ss} \u001b[1m%p %c{2}\u001b[0m :: %m%n

# log to a file
log4j.appender.file=org.apache.log4j.RollingFileAppender
log4j.appender.file.File=metabase.log
log4j.appender.file.MaxFileSize=1MB
log4j.appender.file.MaxBackupIndex=2
log4j.appender.file.layout=org.apache.log4j.PatternLayout
log4j.appender.file.layout.ConversionPattern=%d [%t] %-5p%c - %m%n

# Default log level for all metabase namespaces is INFO. Default log level for everything else is WARN (see top of file)
log4j.logger.metabase=INFO
# For some other Metabase namespaces we want slightly higher log levels for newer/more critical code
log4j.logger.metabase.plugins=DEBUG
log4j.logger.metabase.middleware=DEBUG

# TODO - we can dial these back a bit once we are satisfied the async stuff isn't so new (0.33.0+)
log4j.logger.metabase.async.util=DEBUG
log4j.logger.metabase.middleware.async=DEBUG
log4j.logger.metabase.query-processor.async=DEBUG

# c3p0 connection pools tend to log useless warnings way too often; only log actual errors
log4j.logger.com.mchange=ERROR
