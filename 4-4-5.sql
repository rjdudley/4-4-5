/*
 
      This script is meant for a 4-4-5 calendar, Mon-Sun week.  Every leap year introduces an
            extra week, which we add in November.
            
      User Variables =
 
            FiscalCalendarStart = The date on which a fiscal year starts.  This is used as the base
                  date for all calculations
                  
            EndOfCalendar = The date on which the calendar should end.  This does not have to be
                  the end of a fiscal year, but if it's not, you might have to run the script again
                  to get to the end of the fiscal year.
 
            RunningDaySeed = Usually 1, this is used to measure the number of days since the
                  calendar began, often used for depreciation
            
            RunningPeriodSeed = Usually 1, the number of fiscal months since the original calendar began
      
            RunningWeekSeed = The number of fiscal weeks since the original calendar began
            
            FiscalYearSeed = The starting fiscal year
 
      Iteration Variables--don't mess with these
      
            JdeJulian = the date expressed in JDE's Julian format
            CurrentDate = The calendar date being calculated against
            WorkWeekSeed = Fiscal Week
            WorkPeriodSeed = Fiscal Month
            WorkQuarterSeed = Fiscal Quarter            
            WeekOfMonth = Rolling week of month            
            FiscalWeekEnding = Last day of the fiscal week
            WorkPeriodSeed = Some legacy thing we must have or the world will end.  
				But, used to assign where the extra "leap week" goes.  Based on the 4-4-5 calendar.
            IsLeapYear = 29 days in February extra week in November?
            
	Output Columns (most of these exist to make reports easier)
		DateSID = JDE's Julian Date
		CalendarDate = the date, duh
		Sysdate = YYYYMMDD, based on calendar date
		RunnindDay = the number of days since we installed JDE
		WorkPeriod = roughly correlates to the fiscal month
		RunningPeriod = the number of fiscal months since we installed JDE
		WorkWeek = The fiscal (Mon-Sun) week of the year
		RunningWeek = the number of fiscal weeks since we installed JDE
		FiscalYear = The numeric fiscal year
		FiscalYearLabel = the pretty field used on a report
		WorkQuarter = The fiscal quarter
		FiscalQuarter = Another representation of the fiscal quaruer
		FiscalQuarterLabel = used on reports
		FiscalPeriod = YYYY + WorkQuarter + WorkPeriod (zero-padded)
		FiscalPeriodLabel = used on reports
		FiscalWeek = YYYY + WorkQuarter + WorkPeriod (zero-padded) + week of the fiscal month
		FiscalWeekLabel = used on reports
		CalendarYear = calendar year, duh
		CalendarQuarter = the traditional definition of a quarter
		CalendarQuarterLabel = used on reports
		CalendarMonths = the traditional calendar month
		CalendarMonthLabel = used on some reports
		WeekEnding = the last day of the calendar week (Saturday)
		FiscalWeekEnding = the last day of the fiscal week (Sunday)
		FiscalMonth = Based on the fiscal calendar, relates to the WorkPeriod somehow
		FiscalMonthLabel = used on some reports, based on the FiscalMonth
*/
 
declare @JdeJulian varchar ( 6 ),
      @FiscalCalendarStart datetime ,
      @EndOfCalendar datetime ,
      @CurrentDate datetime ,
      @RunningDaySeed int ,
      @RunningPeriodSeed int ,
      @WorkWeekSeed int ,
      @RunningWeekSeed int ,
      @FiscalYearSeed int ,
      @WorkQuarterSeed int ,
      @WeekOfMonth int ,
      @FiscalWeekEnding datetime ,
      @WorkPeriodSeed int ,
      @IsLeapYear bit
      
declare @FiscalTimePeriods as table (
      DateSID varchar ( 6 ),
      CalendarDate datetime ,
      Sysdate varchar ( 8 ),
      RunningDay int ,
      WorkPeriod int ,
      RunningPeriod int ,
      WorkWeek int ,
      RunningWeek int ,
      FiscalYear int ,
      FiscalYearLabel varchar ( 7 ),
      WorkQuarter int ,
      FiscalQuarter int ,
      FiscalQuarterLabel varchar ( 10 ),
      FiscalPeriod int ,
      FiscalPeriodLabel varchar ( 12 ),
      FiscalWeek int ,
      FiscalWeekLabel varchar ( 17 ),
      CalendarYear int ,
      CalendarQuarter int ,
      CalendarQuarterLabel varchar ( 16 ),
      CalendarMonth int ,
      CalendarMonthLabel varchar ( 10 ),
      WeekEnding datetime ,
      FiscalWeekEnding datetime ,
      FiscalMonth int ,
      FiscalMonthLabel varchar ( 10 )
       )
      
      
/*
      These are user variables, and should be set accordingly
*/       
select @FiscalCalendarStart = '2006/01/02' ,
      @EndOfCalendar = '2009/01/05' ,
      @RunningDaySeed = 2927 ,
      @RunningPeriodSeed = 97 ,
      @RunningWeekSeed = 419 ,
      @FiscalYearSeed = 2006
 
/*
      These are iteration variables, do not mess with these
*/
Select       @WorkPeriodSeed = 1 ,
      @WorkWeekSeed = 1 ,
      @WeekOfMonth = 1 ,
      @IsLeapYear = 0 ,
      @WorkQuarterSeed = 1
 
/*
      The loop is iterated once for each day
*/
set @CurrentDate = @FiscalCalendarStart
 
while @CurrentDate <= @EndOfCalendar
begin
 
       /*
            Each day we need to calculate that day's JDE date and set the fiscal week ending
      */
       select @JdeJulian = convert ( varchar ( 3 ), year ( @CurrentDate )- 1900 ) + right( '000' +
                   convert ( varchar ( 3 ), DATEPART ( DY , @CurrentDate )), 3 )
             , @FiscalWeekEnding = case DATEPART ( DW , @CurrentDate )
                   when 1 then @CurrentDate
                   else DATEADD ( D , 1 , dateadd ( D , 7 - DATEPART ( DW , @CurrentDate ), @CurrentDate ))
               end
            
       insert into @FiscalTimePeriods
       select @JdeJulian as DateSID ,
            @CurrentDate as CalendarDate ,
             CONVERT ( varchar ( 8 ), @CurrentDate , 112 ) as SysDate ,
            @RunningDaySeed as RunningDay ,
            @WorkPeriodSeed as WorkPeriod ,
            @RunningPeriodSeed as RunningPeriod ,
            @WorkWeekSeed as WorkWeek ,
            @RunningWeekSeed as RunningWeek ,
            @FiscalYearSeed as FiscalYear ,
             'FY ' + convert ( varchar ( 4 ), @FiscalYearSeed ) as FiscalYearLabel ,
            @WorkQuarterSeed as WorkQuarter ,
             convert ( int , convert ( varchar ( 4 ), @FiscalYearSeed ) + CONVERT ( varchar ( 2 ), @WorkQuarterSeed ))
                   as FiscalQuarter ,
             'FY ' + convert ( varchar ( 4 ), @FiscalYearSeed ) + ' Q' + CONVERT ( varchar ( 2 ), @WorkQuarterSeed )
                   as FiscalQuarterLabel ,
             convert ( int , convert ( varchar ( 4 ), @FiscalYearSeed ) + CONVERT ( varchar ( 2 ), @WorkQuarterSeed ) +
                   right( '0' + CONVERT ( varchar ( 2 ), @WorkPeriodSeed ), 2 )) as FiscalPeriod ,
             'FY ' + convert ( varchar ( 4 ), @FiscalYearSeed ) + ' M ' + right( '0' +
                   CONVERT ( varchar ( 2 ), @WorkPeriodSeed ), 2 ) as FiscalPeriodLabel ,
             convert ( int , convert ( varchar ( 4 ), @FiscalYearSeed ) + CONVERT ( varchar ( 2 ), @WorkQuarterSeed ) +
                   right( '0' + CONVERT ( varchar ( 2 ), @WorkPeriodSeed ), 2 ) + convert ( char ( 1 ), @WeekOfMonth ))
                   as FiscalWeek ,
             'FY ' + convert ( varchar ( 4 ), @FiscalYearSeed ) + ' M ' +
                   right( '0' + CONVERT ( varchar ( 2 ), @WorkPeriodSeed ), 2 ) + ' WK ' + convert ( char ( 1 ), @WeekOfMonth )
                   as FiscalWeekLabel ,
             YEAR ( @CurrentDate ) as CalendarYear ,
             DATEPART ( QUARTER , @CurrentDate ) as CalendarQuarter ,
             case DATEPART ( QUARTER , @CurrentDate )
                   when 1 then '1st'
                   when 2 then '2nd'
                   when 3 then '3rd'
                   when 4 then '4th'
             end + ' Quarter ' + CONVERT ( varchar ( 4 ), year ( @CurrentDate )) as CalendarQuarterLabel ,
             MONTH ( @CurrentDate ) as CalendarMonth ,
             DATENAME ( MM , @CurrentDate ) as CalendarMonthLabel ,
             dateadd ( D , 7 - DATEPART ( DW , @CurrentDate ), @CurrentDate ) as WeekEnding ,
            @FiscalWeekEnding as FiscalWeekEnding ,
            @WorkPeriodSeed as FiscalMonth ,
             DATENAME ( MM , convert ( varchar ( 4 ), @FiscalYearSeed ) + '/' + convert ( varchar ( 2 ), @WorkPeriodSeed ) + '/1' ) as FiscalMonthLabel
 
       /*
            Iterate the date and increment the RunningDay
      */
       set @CurrentDate = DATEADD ( D , 1 , @CurrentDate )
       select @RunningDaySeed = @RunningDaySeed + 1
 
       /*
            Checks to see if this is a leap year
      */       
       if MONTH ( @CurrentDate ) = 2 and DAY ( @CurrentDate )= 29
             set @IsLeapYear = 1
      
       /*
            Every Monday (start of new fiscal week), increment fiscal counters
      */
       if DATEPART ( DW , @CurrentDate ) = 2
             begin
             /*
                  These months have 5 weeks in the 4-4-5 calendar
            */
             if @WorkPeriodSeed in ( 3 , 6 , 9 , 12 )
                   begin
                         /*
                              Iterate the RunningWeek and WeekOfMonth (roll WeekOfMonth if necessary)
                        */
                         select @RunningWeekSeed = @RunningWeekSeed + 1 ,
                              @WeekOfMonth = case @WeekOfMonth
                                     when 5 then 1
                                     else @WeekOfMonth + 1
                               end ,
                              @WorkWeekSeed = @WorkWeekSeed + 1
                        
                         /*
                              First week of the month we need to update the WorkPeriod and RunninfPeriod
                        */
                         if @WeekOfMonth = 1
                               select @WorkPeriodSeed = @WorkPeriodSeed + 1
                                     , @RunningPeriodSeed = @RunningPeriodSeed + 1
 
                   end
             else
                   begin
                  
                   /*
                        November in leap years get 5 weeks also, so 3rd quarter is 4-5-5
                        Change @WorkPeriodSeed to the month you want to add the extra week into
                  */
                   if @IsLeapYear = 1 and @WorkPeriodSeed = 11
                         begin
                         /*
                              Iterate the RunningWeek and WeekOfMonth (roll WeekOfMonth if necessary)
                        */
                         select @RunningWeekSeed = @RunningWeekSeed + 1 ,
                                    @WeekOfMonth = case @WeekOfMonth
                                           when 5 then 1
                                           else @WeekOfMonth + 1
                                     end ,
                                    @WorkWeekSeed = @WorkWeekSeed + 1
                              
                               /*
                                    First week of the month we need to update the WorkPeriod and RunninfPeriod
                              */
                               if @WeekOfMonth = 1
                                     select @WorkPeriodSeed = @WorkPeriodSeed + 1
                                           , @RunningPeriodSeed = @RunningPeriodSeed + 1                              
                         end
                   else
                         begin
                         /*
                              Iterate the RunningWeek and WeekOfMonth (roll WeekOfMonth if necessary)
                        */
                         select @RunningWeekSeed = @RunningWeekSeed + 1 ,
                                    @WeekOfMonth = case @WeekOfMonth
                                           when 4 then 1
                                           else @WeekOfMonth + 1
                                     end ,
                                    @WorkWeekSeed = @WorkWeekSeed + 1
                              
                               /*
                                    First week of the month we need to update the WorkPeriod and RunninfPeriod
                              */
                               if @WeekOfMonth = 1
                                     select @WorkPeriodSeed = @WorkPeriodSeed + 1
                                           , @RunningPeriodSeed = @RunningPeriodSeed + 1
                         end
                                    
                   end
                  
             /*
                  These months are the first of each quarter (Jan handled below),
                  so we need to roll the WorkQuarter
            */
             if @WeekOfMonth = 1 and @WorkPeriodSeed in ( 4 , 7 , 10 )
                         set @WorkQuarterSeed = @WorkQuarterSeed + 1
 
             /*
                  Check to see if the current week is the start of a new fiscal year.
                  If we've started a new year, we need to reset some iteration variables.
            */
             if @IsLeapYear = 1
                   begin
                   /*
                        The fiscal year following a leap year actually starts in the second
                        week of the year.
                  */
                   if DATEPART ( ISO_WEEK , @CurrentDate ) = 2
                         select @FiscalYearSeed = @FiscalYearSeed + 1
                               , @WorkPeriodSeed = 1
                               , @WorkWeekSeed = 1
                               , @IsLeapYear = 0
                               , @WorkQuarterSeed = 1
                   end
             else
                   begin
                   if DATEPART ( ISO_WEEK , @CurrentDate ) = 1
                         select @FiscalYearSeed = @FiscalYearSeed + 1
                               , @WorkPeriodSeed = 1
                               , @WorkWeekSeed = 1
                               , @IsLeapYear = 0
                               , @WorkQuarterSeed = 1
                   end
 
             end
 
end
 
select * From @FiscalTimePeriods