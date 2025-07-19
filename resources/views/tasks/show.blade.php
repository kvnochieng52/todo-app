@extends('layouts.app')

@section('content')
<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-8">
            <div class="card">
                <div class="card-header">Task Details</div>

                <div class="card-body">
                    <h5>{{ $task->title }}</h5>
                    <p>{{ $task->description }}</p>
                    <p>Status: {{ $task->completed ? 'Completed' : 'Pending' }}</p>
                    <p>Created: {{ $task->created_at->diffForHumans() }}</p>
                    <p>Last updated: {{ $task->updated_at->diffForHumans() }}</p>

                    <div class="mt-3">
                        <a href="{{ route('tasks.edit', $task) }}" class="btn btn-primary">Edit</a>
                        <form action="{{ route('tasks.destroy', $task) }}" method="POST" style="display: inline;">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger"
                                onclick="return confirm('Are you sure?')">Delete</button>
                        </form>
                        <a href="{{ route('tasks.index') }}" class="btn btn-secondary">Back to list</a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection