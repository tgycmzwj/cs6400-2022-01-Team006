from flask import render_template, flash, redirect, url_for, request, session, jsonify
from flask_login import UserMixin, login_user, logout_user, current_user, login_required
from app import app, mysql
from app.forms import LoginForm, RegistrationForm, UpdateForm, ListForm, SearchForm, RateForm, ProposeForm
from app.queries import *
import json
import time

def check_session(session):
    if session.get('logged_in') is None:
        session['logged_in']=False
    if session['logged_in']==False:
        return False
    else:
        return True

def check_can_propose(session):
    cursor = mysql.connection.cursor()
    email=session['username']
    unaccepted=unaccepted_swaps(cursor,email)
    unrated=unrated_swaps(cursor,email)
    return unaccepted,unrated

def check_item(session,itemid):
    cursor=mysql.connection.cursor()
    email=session['username']
    belong_to_me=check_item_owner(cursor,email,itemid)
    already_used=check_item_notavail(cursor,itemid)
    if belong_to_me==0 and already_used==1:
        return False
    return True

def check_swap(session,recordid):
    cursor=mysql.connection.cursor()
    email=session['username']
    if check_swap_asso(cursor,email,recordid)>0:
        return True
    return False


#login page
@app.route('/login',methods=['GET','POST'])
def login():
    email=''
    form = LoginForm()
    if form.validate_on_submit() and request.method=='POST':
        cursor = mysql.connection.cursor()
        #get password
        if '@' in form.username.data:
            email=form.username.data
        else:
            email=login_get_email(cursor,form.username.data)
        result=login_input_email(cursor, email)
        cursor.close()
        #check password
        if result=='ERROR' or result!=form.password.data:
            flash('Wrong Username/Password')
            return redirect(url_for('login'))
        else:
            session['logged_in'] = True
            session['username'] = email
            return redirect(url_for('index'))
    return render_template('login.html', title='Sign In', form=form)

#logout
@app.route('/logout',methods=['GET','POST'])
def logout():
    session.pop('logged_in', None)
    return login()


#registration page
@app.route('/register',methods=['GET','POST'])
def register():
    form=RegistrationForm()
    if form.validate_on_submit():
        cursor = mysql.connection.cursor()
        #check if email already used
        if register_check_email(cursor,form.email.data)>0:
            flash('email is used')
            return render_template('register.html', title='Register', form=form)
        #check if phone number is valid
        if form.phonenumber.data and len(form.phonenumber.data)!=10 and form.phonenumber.data.isdigit()==False:
            flash('Please enter a valid phone number (10-digit number only, no special character)')
            return render_template('register.html', title='Register', form=form)
        #check if phone number already used
        if register_check_phone(cursor,form.phonenumber.data)>0:
            flash('phone is used')
            return render_template('register.html', title='Register', form=form)
        #check if postal code is valid
        if register_check_postalcode(cursor,form.postalcode.data)==0:
            flash('postal code invalid')
            return render_template('register.html', title='Register', form=form)
        #check if city and state are correct
        result=register_check_city(cursor,form.postalcode.data)
        if (result[0].lower()!=form.city.data.lower()) or (result[1].lower()!=form.state.data.lower()):
            flash('Invalid city/state, do you mean city: {}, state: {}'.format(result[0],result[1]))
            return render_template('register.html', title='Register', form=form)
        # store user into to user table
        email=register_insert_user(cursor,
            form.email.data,form.postalcode.data,form.password.data,
            form.firstname.data,form.lastname.data,form.nickname.data)
        # store user into phone table
        if form.phonenumber.data!='':
            phone=register_insert_phone(cursor,
                form.phonenumber.data,form.email.data,form.phonetype.data,int(form.showphone.data))
        cursor.close()
        mysql.connection.commit()
        flash('Congratulations, you are now a registered user!')
        return redirect(url_for('login'))
    return render_template('register.html', title='Register', form=form)

#update info page
@app.route('/update',methods=['GET','POST'])
def update():
    if not check_session(session):
        return login()
    unaccepted,unrated=check_can_propose(session)
    if unaccepted>0 or unrated>0:
        flash('Please accept/reject/rate swaps first')
        return index()
    form=UpdateForm()
    if form.validate_on_submit():
        cursor = mysql.connection.cursor()
        #check if phone number is valid
        if form.phonenumber.data and len(form.phonenumber.data)!=10 and form.phonenumber.data.isdigit()==False:
            flash('Please enter a valid phone number (10-digit number only, no special character)')
            return render_template('update_info.html', title='Register', form=form)
        #check if phone number used by someone else
        if update_check_phone(cursor,form.phonenumber.data,session['username'])>0:
            flash('phone is used by someone else')
            return render_template('update_info.html', title='Register', form=form)
        #check if postal code is valid
        if update_check_postalcode(cursor,form.postalcode.data)==0:
            flash('postal code invalid')
            return render_template('update_info.html', title='Register', form=form)
        #check if city and state are correct
        result=update_check_city(cursor,form.postalcode.data)
        if (result[0].lower()!=form.city.data.lower()) or (result[1].lower()!=form.state.data.lower()):
            flash('Invalid city/state, do you mean city: {}, state: {}'.format(result[0],result[1]))
            return render_template('update_info.html', title='Register', form=form)
        # store user into to user table
        email=update_user(cursor,
            session['username'],form.postalcode.data,form.password.data,
            form.firstname.data,form.lastname.data,form.nickname.data)
        # store user into phone table
        if form.phonenumber.data!='':
            phone=update_phone(cursor,
                form.phonenumber.data,session['username'],form.phonetype.data,int(form.showphone.data))
        cursor.close()
        mysql.connection.commit()
        flash('Congratulations, you have updated your information')
        return redirect(url_for('index'))
    return render_template('update_info.html', title='Update', email=session['username'], form=form)


#home page
@app.route('/',methods=['GET','POST'])
@app.route('/index',methods=['GET','POST'])
def index():
    if not check_session(session):
        return login()
        #return redirect(url_for('login'))
    cursor=mysql.connection.cursor()
    email=session['username']
    user_detail={}
    #sub task: welcome information
    result_welcom_info=menu_welcome(cursor,email)
    #sub task: my rating
    result_rating=my_rating(cursor,email)
    if result_rating is not None:
        result_rating=round(result_rating,2)
    #sub task: number of unaccepted swaps
    result_unaccepted_swaps=unaccepted_swaps(cursor,email)
    #sub task: if any swaps are more than five days old
    result_old_swaps=old_swaps(cursor,email)
    #sub task: unrated swaps
    result_unrated_swaps=unrated_swaps(cursor,email)
    user_detail['first_name'],user_detail['last_name'],user_detail['unaccepted'],user_detail['old'],user_detail['rating'],user_detail['unrated']=result_welcom_info[0],result_welcom_info[1],result_unaccepted_swaps,result_old_swaps,result_rating,result_unrated_swaps
    return render_template('index.html',title='home',user_detail=user_detail)


#list a new item
@app.route('/list',methods=['GET','POST'])
def list():
    if not check_session(session):
        return login()
    unaccepted,unrated=check_can_propose(session)
    if unaccepted>5 or unrated>2:
        flash('Please accept/reject/rate swaps first')
        return index()
    form = ListForm()
    if form.validate_on_submit():
        email = session['username']
        cursor=mysql.connection.cursor()
        #insert to item table
        id=insert_item(cursor,email,form.title.data,form.description.data,form.game_condition.data)
        mysql.connection.commit()
        #insert to board game
        if form.gametype.data=='Board Game':
            result=insert_board(cursor,id)
        #insert to card game
        elif form.gametype.data=='Card Game':
            result=insert_card(cursor,id)
        #insert to video game
        elif form.gametype.data=='Video Game':
            result=insert_video(cursor,id,form.video_platform.data,form.video_media.data)
        #insert to computer game
        elif form.gametype.data=='Computer Game':
            result=insert_computer(cursor,id,form.computer_platform.data)
        #insert to jigsaw puzzle
        elif form.gametype.data=='Jigsaw Puzzle':
            result=insert_jigsaw(cursor,id,form.piececount.data)
        else:
            result='ERROR'
        mysql.connection.commit()
        flash('Your item has been listed! Your item number is '+str(id))
        return redirect(url_for('list'))
    return render_template('list_item.html',title='list',form=form)


#my items
@app.route('/myitem',methods=['GET','POST'])
def myitem():
    if not check_session(session):
        return login()
    email=session['username']
    cursor = mysql.connection.cursor()
    upper_table=view_items_upper(cursor,email)
    lower_table=view_items_lower(cursor,email)
    return render_template('my_item.html',title='my item',upper_table=upper_table,lower_table=lower_table)

#search items
@app.route('/searchitem',methods=['GET','POST'])
def searchitem():
    if not check_session(session):
        return login()
    form=SearchForm()
    if form.validate_on_submit():
        email = session['username']
        cursor = mysql.connection.cursor()
        #search by keyword
        result=''
        if form.search_type.data=='1':
            result=search_keyword(cursor,email,'%'+form.search_keyword.data+'%')
        elif form.search_type.data=='2':
            result=search_my_postalcode(cursor,email)
        elif form.search_type.data=='3':
            result=search_miles(cursor,email,form.search_miles.data)
        elif form.search_type.data=='4':
            result=search_postalcode(cursor,email,form.search_postalcode.data)
        search_content=[form.search_type.data,form.search_keyword.data if form.search_type.data=='1' else '']
        if len(result[1])==0:
            flash('Sorry, no results found')
            return render_template('search_item.html',title='search item',form=form)
        return render_template('search_result.html',title='search result',result_table=result,search_content=search_content)
    return render_template('search_item.html',title='search item',form=form)




# swap history
@app.route('/swaphistory',methods=['GET','POST'])
def swaphistory():
    if not check_session(session):
        return login()
    cursor = mysql.connection.cursor()
    email = session['username']
    if request.method == "POST":
        for entry in request.get_json():
            entry = str(entry)
            if (entry == "N"):
                continue
            arr = entry.split("/")
            record_id = arr[0]
            rating = arr[1]
            role = arr[2]
            assign_rating_to_record((cursor, rating, record_id, role))
        flash("Rating has been submitted!")
        return redirect(url_for('swaphistory'))
    form = RateForm()
    # upper table
    upper_table=swap_history_upper(cursor,email)
    lower_table=swap_history_lower(cursor,email)
    if form.validate_on_submit():
        flash("Ratings are submitted.")
        return redirect(url_for('swaphistory'))
    return render_template('swap_history.html',title='swap history',upper_table=upper_table,lower_table=lower_table, form=form)


# item detail
@app.route('/itemdetail/<itemid>',methods=['GET','POST'])
def itemdetail(itemid):
    if not check_session(session):
        return login()
    if not check_item(session,itemid):
        flash('this item is no longer available')
        return index()
    unaccepted,unrated=check_can_propose(session)
    cursor=mysql.connection.cursor()
    email=session['username']
    result=view_item_detail(cursor,email,itemid)
    item_detail={}
    for i in range(len(result[0])):
        if result[0][i]=='Rating':
            item_detail[result[0][i]] = round(result[1][0][i],2)
        else:
            item_detail[result[0][i]]=result[1][0][i]
    return render_template('item_detail.html',title='item detail',email=email,item_detail=item_detail,unparam=[unaccepted,unrated])


# propose swap
@app.route('/proposeswap/<itemid>', methods=['GET', 'POST'])
def proposeswap(itemid):
    if not check_session(session):
        return login()
    if not check_item(session,itemid):
        flash('This item is no longer available')
        return index()
    unaccepted,unrated=check_can_propose(session)
    if unaccepted>5 or unrated>2:
        flash('Please accept/reject/rate swaps first!')
        return index()
    mysql.connection.autocommit(True)
    cursor = mysql.connection.cursor()
    email = session['username']
    if request.method == "POST":
        #for entry in request.get_json():
            #entry = str(entry)
        data = request.form.get('item_to_propose')
        if data is None:
            flash('You need to select an item for swap')
            return redirect(url_for('proposeswap',itemid=itemid))
        arr = data.split("/")
        proposed_id = arr[0]
        desired_id = arr[1]
        result=insert_pending_swap(cursor, proposed_id, desired_id, datetime.now().date())
        if result=='ERROR':
            flash('You cannot submit this swap, either the desired item is no longer available or it was rejected before')
        else:
            flash("successfully proposed a swap!")
        return redirect(url_for('index'))
    else:
        avail_item = get_avail_item(cursor, email, itemid)
        result = view_item_detail(cursor, email, itemid)
        item_detail = {}
        form = ProposeForm()
        for i in range(len(result[0])):
            item_detail[result[0][i]] = result[1][0][i]
        return render_template('propose_swap.html', title='propose swap', avail_item=avail_item, item_detail=item_detail, form=form)

# # propose swap
# @app.route('/proposeswap/<itemid>',methods=['GET','POST'])
# def proposeswap(itemid):
#     if not check_session(session):
#         return login()
#     if not check_item(session,itemid):
#         flash('You just submitted a swap for this item!')
#         return index()
#     unaccepted,unrated=check_can_propose(session)
#     if unaccepted>5 or unrated>2:
#         flash('Please accept/reject/rate swaps first!')
#         return index()
#     mysql.connection.autocommit(True)
#     cursor = mysql.connection.cursor()
#     email = session['username']
#     form = ProposeForm()
#     avail_item = get_avail_item(cursor, email)
#     item_detail = {}
#     result = view_item_detail(cursor, email, itemid)
#     for i in range(len(result[0])):
#         item_detail[result[0][i]] = result[1][0][i]
#     return render_template('propose_swap.html', title='propose swap', avail_item=avail_item,item_detail=item_detail,desired=itemid,form=form)
#
# @app.route('/receiveproposal',methods=['GET','POST'])
# def receiveproposal():
#     if not check_session(session):
#         return login()
#     cursor = mysql.connection.cursor()
#     email = session['username']
#     if request.method == "POST":
#         results=request.get_json()
#         results=insert_swap(cursor,int(results[1]),int(results[0]))
#         mysql.connection.commit()
#         return index()
#     return json.dumps({'success':True}), 200, {'ContentType':'application/json'}


#accept/reject swaps
@app.route('/pendingswap',methods=['GET','POST'])
def pendingswap():
    if not check_session(session):
        return login()
    unaccepted,unrated=check_can_propose(session)
    if unaccepted==0:
        return index()
    mysql.connection.autocommit(True)
    cursor=mysql.connection.cursor()
    email=session['username']
    pending_swap=show_pending_swap(cursor,email)
    return render_template('pending_swap.html',title='accept/reject swap',pending_swap=pending_swap,message='')

@app.route('/decideswap',methods=['GET','POST'])
def decideswap():
    if not check_session(session):
        return login()
    mysql.connection.autocommit(True)
    cursor = mysql.connection.cursor()
    email = session['username']
    pending_swap = show_pending_swap(cursor, email)
    if request.method == "POST":
        arr = request.json.split("_");
        if arr[0] == "accept":
            accept_or_reject(cursor,arr[1],1)
            contact=display_contact(cursor,int(arr[1]))
            email='Email: '+contact[0]
            name='Name: '+contact[1]
            phone=''
            if (contact[3] is None) or (contact[-1]==0):
                phone='No phone number available'
            else:
                phone='Phone: '+contact[2]
            message='Swap accepted. Contact the proposer to swap items '+'\r\n'+' '+email+' '+name+' '+phone
            flash(message)
            # flash(contact)
        else:
            accept_or_reject(cursor,arr[1],0)
    return json.dumps({'success':True}), 200, {'ContentType':'application/json'}


#rate swaps
@app.route('/rateswap',methods=['GET','POST'])
def rateswap():
    if not check_session(session):
        return login()
    unaccepted,unrated=check_can_propose(session)
    if unrated==0:
        return index()
    mysql.connection.autocommit(True)
    cursor = mysql.connection.cursor()
    email = session['username']
    if request.method == "POST":
        for entry in request.get_json():
            entry = str(entry)
            if(entry == "N"):
                continue
            arr = entry.split("/")
            record_id = arr[0]
            rating = arr[1]
            role = arr[2]
            assign_rating_to_record(cursor, rating, record_id, role)
        #flash("successfully submitted a rating!"+str(request.get_json()))
        return redirect(url_for('rateswap'))
    form = RateForm()
    unrated_swap = show_unrated_swap(cursor, email)
    if form.validate_on_submit():
        flash("Ratings are submitted!")
        return redirect(url_for('rateswap'))
    return render_template('unrated_swap.html',title='rate swap',unrated_swap=unrated_swap,form=form)



#swap detail
@app.route('/swapdetail/<recordid>',methods=['GET','POST'])
def swapdetail(recordid):
    if not check_session(session):
        return login()
    if not check_swap(session,recordid):
        flash('You cannot view a swap that you do not participate in')
        return index()
    cursor=mysql.connection.cursor()
    email=session['username']
    result = view_swap_detail(cursor, email, recordid)
    swap_detail = []
    for i in range(len(result[0])):
        swap_detail.append([result[0][i],result[1][0][i]])
    return render_template('swap_detail.html', title='swap detail', email=email, swap_detail=swap_detail)






















