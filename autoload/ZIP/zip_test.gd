extends Control


func _ready() -> void:
	Zip.start_mission("压缩测试",Zip.Type.ZIP,"D://desktop3/压缩测试/3dmax/","D://desktop3/压缩测试/3dmax.zip")
	Zip.start_mission("解压测试",Zip.Type.UNZIP,"D://desktop3/压缩测试/3dmax.zip","D://desktop3/压缩测试/3dmax/")
	Zip.start_mission("压缩测试",Zip.Type.ZIP,"D://desktop3/压缩测试/3dmax/","D://desktop3/压缩测试/3dmax.zip")
	Zip.start_mission("解压测试",Zip.Type.UNZIP,"D://desktop3/压缩测试/3dmax.zip","D://desktop3/压缩测试/3dmax/")
	Zip.start_mission("压缩测试",Zip.Type.ZIP,"D://desktop3/压缩测试/3dmax/","D://desktop3/压缩测试/3dmax.zip")
	Zip.start_mission("解压测试",Zip.Type.UNZIP,"D://desktop3/压缩测试/3dmax.zip","D://desktop3/压缩测试/3dmax/")
	Zip.start_mission("压缩测试",Zip.Type.ZIP,"D://desktop3/压缩测试/3dmax/","D://desktop3/压缩测试/3dmax.zip")
	Zip.start_mission("解压测试",Zip.Type.UNZIP,"D://desktop3/压缩测试/3dmax.zip","D://desktop3/压缩测试/3dmax/")

	pass
