--[[
		This script will run every day and check if the following day
		is a public holiday. Ideally this check could be done via a
		free (or cheap) service with a JSON API. Until that can be found 
		I will hard code the Western Australian public holidays.

		If the following day is a public holiday this script will
		perform any necessary tasks.
			1. Create public leave requests in WageBase
				 (The reason that this isn't done once at the beginning of the
					year is that new staff will be employed during the year and
					some staff may move from casual to permanent and therefore
					become eligible for paid public holidays)
			2.  TBA

--]]

--
holidays ={}

holidays['1/1/2014'] = "New Year's Day"
holidays['27/1/2014'] = "Australia Day"	
holidays['3/3/2014'] = "Labour Day" 
holidays['18/4/2014'] = "Good Friday"
holidays['21/4/2014'] = "Easter Monday"
holidays['25/4/2014'] = "Anzac Day"
holidays['2/6/2014'] = "Western Australia Day"
holidays['29/9/2014'] = "Queen's Birthday"
holidays['25/12/2014'] = "Christmas Day"
holidays['26/12/2014'] = "Boxing Day"

gmt = os.time()
awst = gmt + 8*60*60
future = os.date("*t", awst + 24*60*60)
tomorrow = future.day.."/"..future.month.."/"..future.year
tomorrow = '2/6/2014' -- testing

if holidays[tomorrow] == nil then 
	return 200
	end

-- Tomorrow is a public holiday
log(holidays[tomorrow])