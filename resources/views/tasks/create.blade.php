@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Create New Task</div>

                <div class="card-body">
                    <form method="POST" action="{{ route('tasks.store') }}">
                        @csrf

                        <div class="form-group mb-3">
                            <label for="title">Title</label>
                            <input type="text" class="form-control" id="title" name="title" required>
                        </div>

                        <div class="form-group mb-3">
                            <label for="description">Description</label>
                            <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                        </div>

                        <button type="submit" class="btn btn-primary">Create Task</button>
                        <a href="{{ route('tasks.index') }}" class="btn btn-secondary">Cancel</a>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection