import tensorflow as tf

print("TENSORFLOW GPU devices: " + str(tf.config.list_physical_devices('GPU')))
print("TENSORFLOW CPU devices: " + str(tf.config.list_physical_devices('CPU')))