from flask_wtf import FlaskForm
from wtforms import StringField, SelectField, PasswordField, BooleanField, SubmitField, IntegerField, RadioField
from wtforms.validators import DataRequired,NumberRange,optional,Email


# login form
class LoginForm(FlaskForm):
    username = StringField('Email/Phone', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    submit = SubmitField('Sign In')


# registeration form
class RegistrationForm(FlaskForm):
    email = StringField('Email', validators=[DataRequired(),Email()])
    password = StringField('Password', validators=[DataRequired()])
    nickname = StringField('Nickname', validators=[DataRequired()])
    firstname = StringField('First Name', validators=[DataRequired()])
    lastname = StringField('Last Name', validators=[DataRequired()])
    city = StringField('City', validators=[DataRequired()])
    state = StringField('State', validators=[DataRequired()])
    postalcode = StringField('Postal Code', validators=[DataRequired()])
    phonenumber = StringField('Phone Number (optional)')
    phonetype = SelectField('Phone Type',choices=[('home','Home'),('work','Work'),('mobile','Mobile')],default='mobile')
    showphone = BooleanField('Show Phone number in swaps')
    submit = SubmitField('Submit')


# update form
class UpdateForm(FlaskForm):
    #email = StringField('Email', validators=[DataRequired()])
    password = StringField('Password', validators=[DataRequired()])
    nickname = StringField('Nickname', validators=[DataRequired()])
    firstname = StringField('First Name', validators=[DataRequired()])
    lastname = StringField('Last Name', validators=[DataRequired()])
    city = StringField('City', validators=[DataRequired()])
    state = StringField('State', validators=[DataRequired()])
    postalcode = StringField('Postal Code', validators=[DataRequired()])
    phonenumber = StringField('Phone Number (optional)')
    phonetype = SelectField('Phone Type',choices=[('home','Home'),('work','Work'),('mobile','Mobile')],default='mobile')
    showphone = BooleanField('Show Phone number in swaps')
    submit = SubmitField('Submit')


#list item form
class ListForm(FlaskForm):
    gametype = SelectField('Game Type', choices=['Board Game','Card Game','Video Game','Computer Game','Jigsaw Puzzle'],default='Card Game',validators=[DataRequired()])
    title = StringField('Title',validators=[DataRequired()])
    game_condition = SelectField('Condition',choices=['Mint','Like New','Lightly Used','Moderately Used','Heavily Used','Damaged/Missing parts'],default='Mint',validators=[DataRequired()])
    description = StringField('Description')
    video_platform = SelectField('Platform',choices=['Nintendo','PlayStation','Xbox'],default='Nintendo',validators=[DataRequired()])
    video_media = SelectField('Media',choices=['Linux','macOS','Windows'],default='Windows',validators=[DataRequired()])
    computer_platform = SelectField('Platform',choices=['optical disc','game card','cartridge'],default='game card',validators=[DataRequired()])
    piececount = IntegerField('Piece Count', validators=[NumberRange(min=1)],default=1)
    submit = SubmitField('Submit')

#search item form
class SearchForm(FlaskForm):
    # search_box = StringField('', default='hh', validators=[DataRequired()])
    search_type=RadioField('Search',choices=[(1,'By keyword'),(2,'In my postal code'),(3,'Within miles of me'),(4,'In postal code')],default=1,validators=[DataRequired()])
    search_keyword=StringField('',validators=[],default='keyword')
    search_miles=IntegerField('',validators=[optional()],default=0)
    search_postalcode=StringField('',validators=[],default='10001')
    submit=SubmitField('Search!')

#rate swap form
class RateForm(FlaskForm):
    submit=SubmitField('Save My Rating')

# Propose swap form
class ProposeForm(FlaskForm):
    submit = SubmitField('Confirm')
