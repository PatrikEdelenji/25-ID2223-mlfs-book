import hopsworks

project = hopsworks.login()
fs = project.get_feature_store()

energy_fg = fs.get_feature_group('energy_consumption', version=1)
weather_fg = fs.get_feature_group('weather_finland', version=1)

print('Energy FG primary_key:', energy_fg.primary_key)
print('Energy FG event_time:', energy_fg.event_time)
print('Weather FG primary_key:', weather_fg.primary_key)
print('Weather FG event_time:', weather_fg.event_time)
