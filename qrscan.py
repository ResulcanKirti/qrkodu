from flask import Flask, request, jsonify
import os
import logging
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
UPLOAD_FOLDER = os.path.join(BASE_DIR, 'uploads')

app = Flask(__name__)
CORS(app, supports_credentials=True)

logger = logging.getLogger('project_manager')
logger.setLevel(logging.INFO)

file_handler = logging.FileHandler('project_manager.log')
file_handler.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///project_manager.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

db = SQLAlchemy(app)
migrate = Migrate(app, db)

class Project(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String, nullable=False)
    description = db.Column(db.String, nullable=False)
    status = db.Column(db.String, nullable=False, default='Active')
    deadline = db.Column(db.Date, nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    settings = db.relationship('ProjectSetting', backref='project', lazy=True)
    devices = db.relationship('Device', backref='project', lazy=True)

class ProjectSetting(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    project_id = db.Column(db.Integer, db.ForeignKey('project.id'), nullable=False)
    key = db.Column(db.String, nullable=False)
    default_value = db.Column(db.String, nullable=True)

class Device(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    project_id = db.Column(db.Integer, db.ForeignKey('project.id'), nullable=False)
    name = db.Column(db.String, nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    settings = db.relationship('DeviceSetting', backref='device', lazy=True)

class DeviceSetting(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    device_id = db.Column(db.Integer, db.ForeignKey('device.id'), nullable=False)
    project_setting_id = db.Column(db.Integer, db.ForeignKey('project_setting.id'), nullable=False)
    value = db.Column(db.String, nullable=False)
    project_setting = db.relationship('ProjectSetting', backref=db.backref('device_settings', lazy=True))

@app.route('/api/projects', methods=['GET'])
def get_projects():
    projects = Project.query.all()
    result = [
        {
            'id': project.id,
            'name': project.name,
            'description': project.description,
            'deadline': project.deadline.strftime('%Y-%m-%d'),
            'status': project.status,
            'created_at': project.created_at.strftime('%Y-%m-%d %H:%M:%S'),
        }
        for project in projects
    ]
    return jsonify(result), 200

@app.route('/api/projects/<int:project_id>/settings', methods=['GET'])
def get_project_settings(project_id):
    project = db.session.get(Project, project_id)
    if project is None:
        return jsonify({'message': 'Project not found'}), 404

    settings = project.settings
    settings_data = [{'key': s.key, 'default_value': s.default_value} for s in settings]
    return jsonify(settings_data), 200

@app.route('/api/projects', methods=['POST'])
def create_project():
    data = request.json
    if not data:
        return jsonify({'error': 'No data provided'}), 400

    try:
        new_project = Project(
            name=data.get('name'),
            description=data.get('description'),
            deadline=datetime.strptime(data.get('deadline'), '%Y-%m-%d').date(),
            status=data.get('status', 'Active'),
        )
        db.session.add(new_project)
        db.session.commit()
        return jsonify({'message': 'Proje başarıyla oluşturuldu', 'project_id': new_project.id}), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error: {str(e)}")
        return jsonify({'error': f'Proje oluşturma başarısız: {str(e)}'}), 500

@app.route('/api/projects/<int:project_id>/devices', methods=['POST'])
def create_device(project_id):
    project = db.session.get(Project, project_id)
    if project is None:
        return jsonify({'message': 'Project not found'}), 404

    data = request.json
    if not data or not data.get('name'):
        return jsonify({'error': 'No device name provided'}), 400

    try:
        new_device = Device(
            name=data.get('name'),
            project_id=project_id,
        )
        db.session.add(new_device)
        db.session.commit()
        
        device_settings_data = data.get('settings', [])
        for ds in device_settings_data:
            device_setting = DeviceSetting(
                device_id=new_device.id,
                project_setting_id=ds.get('project_setting_id'),
                value=ds.get('value')
            )
            db.session.add(device_setting)
        db.session.commit()

        return jsonify({'message': 'Cihaz başarıyla oluşturuldu', 'device_id': new_device.id}), 201
    except Exception as e:
        db.session.rollback()
        logger.error(f"Error: {str(e)}")
        return jsonify({'error': f'Cihaz oluşturma başarısız: {str(e)}'}), 500

@app.route('/api/projects/<int:project_id>/devices', methods=['GET'])
def get_devices(project_id):
    project = db.session.get(Project, project_id)
    if project is None:
        return jsonify({'message': 'Project not found'}), 404

    devices = project.devices
    result = []
    for device in devices:
        settings = [
            {
                'project_setting_id': s.project_setting_id,
                'value': s.value
            }
            for s in device.settings
        ]
        result.append({
            'id': device.id,
            'name': device.name,
            'created_at': device.created_at.strftime('%Y-%m-%d %H:%M:%S'),
            'settings': settings
        })
    return jsonify(result), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=9998)
