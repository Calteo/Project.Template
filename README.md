# Project.Template
A template for projects

The documentation for this project is in the doxfx_project.

During development the docs are transformed into HTML by DoxFX and published on github pages.

Things to do after creating a new project from this template:
- Change documentation
	- Enter project name into docfx.json, 
- Change the solution name and project name in src folder.
	- Add a new project to the solution if needed.
- Change to the github action (main.yml) 
	- Change names in the env section to match the new project.
	- Check which steps are needed for the new project and remove the others.
- Update the README.md file.