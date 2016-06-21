// _ = require("./underscore");

var Meeting = function () {
    this.by_person = {};
    this.by_id = {};
    this.statuses = ["accept", "decline", "unknown", "tentative"];
};

Meeting.prototype.add = function(data) {
    var m = this;
    if (_.isString(data)) { data = JSON.parse(data) }

    var id = data.id;
    _.each(data.responses, function(r){
	var email = r['t:Mailbox']['t:EmailAddress'];
	
	m.by_person[email] = m.by_person[email] || { responses: { accept: [], decline: [], unknown: [], tentative: [] }, name: '', invites: [] };

	m.by_person[email]['name'] = r['t:Mailbox']['t:Name'];
	m.by_person[email]['responses'][r['t:ResponseType'].toLowerCase()].push(id)
	m.by_person[email]['invites'].push(id)
	m.by_person[email]['name'] = r['t:Mailbox']['t:Name'];
	
	var p = { email: email, name: r['t:Mailbox']['t:Name'] };
	m.by_id[id] = m.by_id[id] || { responses: { accept: [], decline: [], unknown: [], tentative: [] }, subject: '', start: '', end: '', people: []  };
	m.by_id[id].responses[r['t:ResponseType'].toLowerCase()].push(p);
	m.by_id[id].people.push(p);
    });
    return m.by_person;
};

Meeting.prototype.ids = function(){
    return _.keys(this.by_id);
};

Meeting.prototype.invitees = function(){
    var p = this.by_person
    return _.map(_.keys(p), function(k){ return { email: k, name: p[k].name } });
};


Meeting.prototype.summary = function(ids) {
    var p = this.byPerson(ids);
    var people = _.keys(p)
    people = _.chain(people);

    var o = {};

    o.accept  =   people.filter(function(i){ return p[i].responses.accept.length > 0 })
    o.decline =   people.filter(function(i){ return p[i].responses.decline.length == p[i].invites.length })
    o.unknown =   people.filter(function(i){ return p[i].responses.unknown.length == p[i].invites.length })
    o.tentative = people.filter(function(i){ return p[i].responses.tentative.length > 0 && p[i].responses.accept.length == 0 })
    o.total =     people.size().value();

    // put name and e-mail on each item
    _.each(this.statuses, function(s){
    	o[s] = o[s].map(function(i) { return { name: p[i].name, email: i }  }).value()
    })

    return o;
};

Meeting.prototype.byPerson = function(ids) {
    // data contains the list of meeting id's

    if (_.isString(ids)) { ids = [ids] }
    var p = Object.assign({}, this.by_person);
    var statuses = this.statuses;
    if (ids) {
	var filter = _.object(ids, _.map(ids, function(){ return 1 }))
	var people = _.keys(p)

	_.each(people, function(person){
	    p[person].invites = _.filter(p[person].invites, function(i) { return filter[i] > 0 });
	    if (p[person].invites.length > 0){
		_.each(statuses, function(s){
		    p[person].responses[s] = _.filter(p[person].responses[s], function(i) { return filter[i] > 0 });
		});
	    } else {
		delete p[person];
	    }
	})
    } 
    return p
};

// module.exports = Meeting
