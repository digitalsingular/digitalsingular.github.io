<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE log4j:configuration SYSTEM "log4j.dtd" >
<log4j:configuration>

	<appender name="hibernate_log"
		class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="%d{ABSOLUTE} %p %c - %m%n" />
		</layout>
	</appender>

	<appender name="stdout" class="org.apache.log4j.ConsoleAppender">
		<layout class="org.apache.log4j.PatternLayout">
			<param name="ConversionPattern" value="%d{ABSOLUTE} %p %c - %m%n" />
		</layout>
	</appender>
	
	<logger name="org.hibernate.SQL">
		<level value="trace" />
		<appender-ref ref="hibernate_log" />
	</logger>

	<logger name="org.hibernate.type.descriptor.sql.BasicBinder">
		<level value="trace" />
		<appender-ref ref="hibernate_log" />
	</logger>
	
	<root>
		<priority value="error" />
		<appender-ref ref="stdout" />
	</root>
</log4j:configuration>
